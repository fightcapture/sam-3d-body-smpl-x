FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

WORKDIR /app

RUN apt update && apt upgrade -y && apt install -y git wget curl build-essential python3-pip libegl1-mesa libegl1-mesa-dev libgl1-mesa-glx libglib2.0-0 libosmesa6-dev freeglut3-dev fuse3 && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /app/miniconda3
RUN eval "$(/app/miniconda3/bin/conda shell.bash hook)"
# restart shell to apply conda changes
RUN source /app/.bashrc
RUN conda init
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Install PyTorch with CUDA support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Test CUDA availability with Python
CMD ["python3", "-c", "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA device: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"None\"}')"]