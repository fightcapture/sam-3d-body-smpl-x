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
EOF
```

# Momentum human rig 70

```
{
  "keypoints": {
    "0": "Pelvis Center (Root)",
    "1": "Left Hip",
    "2": "Right Hip",
    "3": "Left Knee",
    "4": "Right Knee",
    "5": "Left Ankle",
    "6": "Right Ankle",
    "7": "Left Toe Base",
    "8": "Right Toe Base",
    "9": "Lower Spine",
    "10": "Middle Spine",
    "11": "Upper Spine",
    "12": "Neck Base",
    "13": "Top of Head",
    "14": "Left Shoulder",
    "15": "Right Shoulder",
    "16": "Left Elbow",
    "17": "Right Elbow",
    "18": "Left Wrist",
    "19": "Right Wrist",
    "20": "Left Eye",
    "21": "Right Eye",
    "22": "Nose Tip",
    "23": "Left Ear",
    "24": "Right Ear",
    "25": "Left Hand Wrist Attachment",
    "26": "Left Thumb Base (MCP)",
    "27": "Left Thumb Middle (PIP)",
    "28": "Left Thumb Outer (DIP)",
    "29": "Left Thumb Tip",
    "30": "Left Index Finger Base (MCP)",
    "31": "Left Index Finger Middle (PIP)",
    "32": "Left Index Finger Outer (DIP)",
    "33": "Left Index Finger Tip",
    "34": "Left Middle Finger Base (MCP)",
    "35": "Left Middle Finger Middle (PIP)",
    "36": "Left Middle Finger Outer (DIP)",
    "37": "Left Middle Finger Tip",
    "38": "Left Ring Finger Base (MCP)",
    "39": "Left Ring Finger Middle (PIP)",
    "40": "Left Ring Finger Outer (DIP)",
    "41": "Left Ring Finger Tip",
    "42": "Left Pinky Finger Base (MCP)",
    "43": "Left Pinky Finger Middle (PIP)",
    "44": "Left Pinky Finger Outer (DIP)",
    "45": "Left Pinky Finger Tip",
    "46": "Left Palm Center",
    "47": "Right Hand Wrist Attachment",
    "48": "Right Thumb Base (MCP)",
    "49": "Right Thumb Middle (PIP)",
    "50": "Right Thumb Outer (DIP)",
    "51": "Right Thumb Tip",
    "52": "Right Index Finger Base (MCP)",
    "53": "Right Index Finger Middle (PIP)",
    "54": "Right Index Finger Outer (DIP)",
    "55": "Right Index Finger Tip",
    "56": "Right Middle Finger Base (MCP)",
    "57": "Right Middle Finger Middle (PIP)",
    "58": "Right Middle Finger Outer (DIP)",
    "59": "Right Middle Finger Tip",
    "60": "Right Ring Finger Base (MCP)",
    "61": "Right Ring Finger Middle (PIP)",
    "62": "Right Ring Finger Outer (DIP)",
    "63": "Right Ring Finger Tip",
    "64": "Right Pinky Finger Base (MCP)",
    "65": "Right Pinky Finger Middle (PIP)",
    "66": "Right Pinky Finger Outer (DIP)",
    "67": "Right Pinky Finger Tip",
    "68": "Right Palm Center",
    "69": "Left Heel",
    "70": "Right Heel"
  }
}
```