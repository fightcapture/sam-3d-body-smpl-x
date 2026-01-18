# Setting up Google Drive shared drive over rclone on Lambda Labs GPUs

* Create a shared folder in Google Drive
    * Inside the shared folder, create an `input` folder with frames
    * Inside the shared folder, Create an empty `output` folder
* Create a GPU instance on Lambda Labs (tested with A10)
    * `ssh` to the GPU instance
    * `curl https://rclone.org/install.sh | bash`
    * `sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf`
    * `rclone config`
    * Set up the remote, name it `fightcapture`
    * `rclone mount fightcapture: /home/ubuntu/gdrive-fightcapture --allow-other --vfs-cache-mode writes --daemon`

# Exctracting 3D keypoints from images on Lambda Labs GPUs

* Request access to https://huggingface.co/facebook/sam-3d-body-dinov3
* Get your `HF_TOKEN` from https://huggingface.co/settings/tokens
* `ssh` to your GPU instance
    * `git clone https://github.com/fightcapture/sam-3d-body-smpl-x.git`
    * `cd sam-3d-body-smpl-x`
    * `sudo docker build --build-arg HF_TOKEN=... -t sam-3d-body-smpl-x .`
    * `sudo docker run --gpus all -v /home/ubuntu/gdrive-fightcapture/input:/app/input -v /home/ubuntu/gdrive-fightcapture/output:/app/output sam-3d-body-smpl-x`
    * Once the run is finished, you'll find the output in `gdrive-fightcapture/output`