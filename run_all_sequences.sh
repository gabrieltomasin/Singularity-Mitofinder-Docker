#!/bin/bash

# Check if the input and output folders are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <input_folder> <output_folder> [additional_args...]"
  exit 1
fi

# Assign the input and output folders
INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"

# Base command for Singularity
COMMAND="singularity run -B $INPUT_FOLDER:$INPUT_FOLDER -B $OUTPUT_FOLDER:$OUTPUT_FOLDER /home/ubuntu/mitofinder_v1.4.2.sif"

# Shift positional arguments to handle additional args
shift 2

# Check if the input folder exists
if [ ! -d "$INPUT_FOLDER" ]; then
  echo "Error: Input folder '$INPUT_FOLDER' does not exist."
  exit 1
fi

# Create the output folder if it doesn't exist
if [ ! -d "$OUTPUT_FOLDER" ]; then
  mkdir -p "$OUTPUT_FOLDER"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create output folder '$OUTPUT_FOLDER'."
    exit 1
  fi
fi

# Find all .contigs.fasta files recursively in the input folder
find "$INPUT_FOLDER" -type f -name "*.contigs.fasta" | while read -r FILE; do
  echo "Processing file: $FILE"

  JOB_NAME=$(basename "$FILE" .contigs.fasta)

  # Construct the full command with arguments
  FULL_COMMAND="$COMMAND -a '$FILE' -j '${JOB_NAME}' ${*}"

  # Debugging: Print the full command
  echo "Executing command: $FULL_COMMAND"

  # Execute the command
  eval "$FULL_COMMAND"

  # Check if the command succeeded
  if [ $? -ne 0 ]; then
    echo "Error: Command failed for file '$FILE'."
    exit 1
  fi

done

echo "All files processed successfully."
