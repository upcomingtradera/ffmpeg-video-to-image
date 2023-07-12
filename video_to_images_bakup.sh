#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_video_path> <output_dir> [frame_rate] [frames_per_folder]"
    echo "Extracts one frame per second from the input video and writes them to the output directory, creating subfolders every duration such that a specified number of frames are in each subfolder."
    echo "Defaults to 60 frames per second and 10000 frames per folder if no third and fourth argument is given."
    exit 1
fi

input_video_path="$1"
output_dir="$2"
frame_rate=${3:-60}
frames_per_folder=${4:-10000}

# Get input video name without extension
input_video_name=$(basename "${input_video_path%.*}")

# Calculate the duration of the video in seconds.
duration=$(ffprobe -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_video_path" | cut -d. -f1)
echo "Video duration: $duration seconds"

# How many seconds of the video each directory will hold to have around the specified number of images.
seconds_per_folder=$((frames_per_folder/frame_rate))

for ((start=0; start<duration; start+=seconds_per_folder)); do
    end=$((start+seconds_per_folder-1))

    # Create a new directory for this chunk
    folder_name="$output_dir/$input_video_name/parts_$(printf "%03d" $((start / seconds_per_folder + 1)))"
    mkdir -p "$folder_name"

    echo "Processing frames from $start to $end seconds"
    ffmpeg -y -i "$input_video_path" -vf "select=between(t\,$start\,$end),setpts=PTS-STARTPTS,fps=1" "$folder_name/out_%09d.jpeg"
done
