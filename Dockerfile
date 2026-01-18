FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
SHELL ["/bin/bash", "-c"]
WORKDIR /app

RUN apt update && apt upgrade -y && apt install -y git wget curl build-essential python3-pip libegl1-mesa libegl1-mesa-dev libgl1-mesa-glx libglib2.0-0 libosmesa6-dev freeglut3-dev fuse3 && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /app/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/app/miniconda3/bin:${PATH}"

RUN conda init bash && \
    conda config --set auto_activate_base true && \
    conda config --set channel_priority strict

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create conda environment (disable safety checks for faster build)
RUN conda create -n sam-3d-body python=3.11 -y --solver=classic

# Activate environment and install packages
RUN echo "source /app/miniconda3/etc/profile.d/conda.sh && conda activate sam-3d-body" >> ~/.bashrc

# Install PyTorch with CUDA 12.1 in the conda environment
RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install other dependencies
RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip install pytorch-lightning pyrender opencv-python yacs scikit-image einops timm dill pandas rich hydra-core hydra-submitit-launcher hydra-colorlog pyrootutils webdataset chump networkx==3.2.1 roma joblib seaborn wandb appdirs appnope ffmpeg cython jsonlines pytest xtcocotools loguru optree fvcore black pycocotools tensorboard huggingface_hub

# Install detectron2
RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip install 'git+https://github.com/facebookresearch/detectron2.git@a1ce2f9' --no-build-isolation --no-deps

# Install MoGe
RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip install git+https://github.com/microsoft/MoGe.git

RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip uninstall -y PyOpenGL

RUN source /app/miniconda3/etc/profile.d/conda.sh && \
    conda activate sam-3d-body && \
    pip install git+https://github.com/mmatl/pyopengl.git

# Make conda environment activate on shell start
RUN echo "conda activate sam-3d-body" >> ~/.bashrc

RUN git clone https://github.com/facebookresearch/sam-3d-body.git
WORKDIR /app/sam-3d-body
RUN hf download facebook/sam-3d-body-dinov3 --local-dir checkpoints/sam-3d-body-dinov3

# Test CUDA availability with Python (using the conda environment)
CMD ["/bin/bash", "-c", "source /app/miniconda3/etc/profile.d/conda.sh && conda activate sam-3d-body && python -c \"import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \\\"None\\\"}')\""]