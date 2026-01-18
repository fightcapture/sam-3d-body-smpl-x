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

# Terminating the GPU instance after the job is finished

Get your Lambda Labs API key from https://cloud.lambda.ai/api-keys/cloud-api

```
nohup bash -c '
  INSTANCE_ID=$(cloud-init query -f "{{instance_id}}")
  LL_API_KEY=...
  sudo docker run --gpus all -v /home/ubuntu/gdrive-fightcapture/input:/app/input -v /home/ubuntu/gdrive-fightcapture/output:/app/output sam-3d-body-smpl-x
  curl -u "$LL_API_KEY:" -X POST https://cloud.lambda.ai/api/v1/instance-operations/terminate \
  -d "{\"instance_ids\": [\"$INSTANCE_ID\"]}" \
  -H "Content-Type: application/json"
' > job_output.log 2>&1 &
```