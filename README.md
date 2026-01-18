# Setting up Google Drive shared drive over rclone on Lambda Labs GPUs

* Create a shared folder in Google Drive
    * Inside the shared folder, create an `input` folder with frames
    * Inside the shared folder, Create an empty `output` folder
* Create a GPU instance on Lambda Labs (tested with A10)
    * `ssh` to the GPU instance
    * `curl https://rclone.org/install.sh | sudo bash`
    * `sudo apt  install jq`
    * `sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf`
    * `rclone config`
    * Set up the remote, name it `fightcapture`
    * `mkdir gdrive-fightcapture`
    * `rclone mount fightcapture: gdrive-fightcapture --allow-other --vfs-cache-mode writes --daemon`

# Set up the keypoint extractor

* Request access to https://huggingface.co/facebook/sam-3d-body-dinov3
* Get your `HF_TOKEN` from https://huggingface.co/settings/tokens
* `ssh` to your GPU instance
    * `git clone https://github.com/fightcapture/sam-3d-body-smpl-x.git`
    * `cd sam-3d-body-smpl-x`
    * `sudo docker build --build-arg HF_TOKEN=... -t sam-3d-body-smpl-x .`

# Extract keypoints

* `ssh` to your GPU instance
    * `sudo docker run --gpus all -v /home/ubuntu/gdrive-fightcapture/input:/app/input -v /home/ubuntu/gdrive-fightcapture/output:/app/output sam-3d-body-smpl-x`
    * Once the run is finished, you'll find the output in `gdrive-fightcapture/output`

# Extract keypoints and terminate the GPU instance after the job is finished

Get your Lambda Labs API key from https://cloud.lambda.ai/api-keys/cloud-api

`ssh` to your GPU instance, and:

```
nohup bash << 'EOF' > job.log 2>&1 &
  LL_API_KEY=...
  INSTANCE_ID=$(curl --request GET --url "https://cloud.lambda.ai/api/v1/instances" --header "accept: application/json" --user "$LL_API_KEY:" | jq -r ".data[0].id")
  sudo docker run --gpus all -v /home/ubuntu/gdrive-fightcapture/input:/app/input -v /home/ubuntu/gdrive-fightcapture/output:/app/output sam-3d-body-smpl-x  
  curl -u "$LL_API_KEY:" -X POST https://cloud.lambda.ai/api/v1/instance-operations/terminate -d "{\"instance_ids\": [\"$INSTANCE_ID\"]}" -H "Content-Type: application/json"
EOF```