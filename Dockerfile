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
    echo "conda config --set channel_priority strict" >> ~/.bashrc
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN conda create -n sam-3d-body python=3.11 -y
RUN conda activate sam-3d-body

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip install pytorch-lightning pyrender opencv-python yacs scikit-image einops timm dill pandas rich hydra-core hydra-submitit-launcher hydra-colorlog pyrootutils webdataset chump networkx==3.2.1 roma joblib seaborn wandb appdirs appnope ffmpeg cython jsonlines pytest xtcocotools loguru optree fvcore black pycocotools tensorboard huggingface_hub
RUN pip install 'git+https://github.com/facebookresearch/detectron2.git@a1ce2f9' --no-build-isolation --no-deps
RUN pip install git+https://github.com/microsoft/MoGe.git


# Test CUDA availability with Python
CMD ["python3", "-c", "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"None\"}')"]
