* Request access to https://huggingface.co/facebook/sam-3d-body-dinov3
* Get your `HF_TOKEN`
* Create a GPU instance on Lambda Labs (tested with A10)
* ssh to the instance
* `mkdir input` and import the input frames (images) to this dir (via scp, rclone or other means)
* `mkdir output`
* `git clone` this repository and `cd` to the repository
* `sudo docker build --build-arg HF_TOKEN=... -t sam-3d-body-smpl-x .`
* `sudo docker run --gpus all -v /home/ubuntu/input:/app/input -v /home/ubuntu/output:/app/output sam-3d-body-smpl-x`
* Once the run is finished, you'll find the output in `output`