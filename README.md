# Singularity with MitoFinder Docker Image

This repository contains a Dockerfile to build a Docker image with Singularity and MitoFinder pre-installed. The image is designed to run with privileged access to support Singularity's functionality.

You can find the original MitoFinder repo here: https://github.com/RemiAllio/MitoFinder

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Building the Docker Image](#building-the-docker-image)
3. [Running the Container](#running-the-container)
4. [Interacting with Singularity and MitoFinder](#interacting-with-singularity-and-mitofinder)
5. [Notes](#notes)

---

## Prerequisites

Before proceeding, ensure you have the following installed on your system:
- **Docker**: Install Docker by following the official [Docker installation guide](https://docs.docker.com/get-docker/).
- **Git** (optional): If you want to clone this repository.

---

## Building the Docker Image

Run the following command to build the Docker image:
```bash
docker build -t singularity-mitofinder:latest .
```
- `-t singularity-mitofinder:latest`: Tags the image with the name `singularity-mitofinder` and the tag `latest`.

- `.`: Specifies the build context (current directory).

The build process may take several minutes, as it involves compiling Singularity and pulling the MitoFinder Singularity image.

---

## Running the Container

To run the container interactively with privileged access, use the following command:

```bash
docker run --privileged -it --rm \
  -v /path/to/input:/data/input \
  -v /path/to/output:/data/output \
  bash
```

### Explanation of Flags:
- `--privileged`: Grants the container elevated privileges, which is required for Singularity to function properly.
- `-it`: Runs the container in interactive mode with a terminal.
- `--rm`: Automatically removes the container when it exits.

---

## Interacting with Singularity and MitoFinder

Once inside the container, you can use Singularity to run the pre-installed MitoFinder image:

### Example Command:
```bash
singularity exec /home/ubuntu/mitofinder_v1.4.2.sif mitofinder -h
```

This will display the help menu for MitoFinder.

### Running a MitoFinder Analysis:
1. Prepare your input files on your host system.
2. Mount the directory containing your files to the container using `-v`:
   ```bash
   docker run --privileged -it --rm -v /path/to/data:/data singularity-mitofinder:latest
   ```
3. Inside the container, navigate to the mounted directory:
   ```bash
   cd /data
   ```
4. Run MitoFinder with your input data:
   ```bash
   singularity exec /home/ubuntu/mitofinder_v1.4.2.sif mitofinder -a input.fasta [additional_mitofinder_args...]
   ```

### Running a batch annotation over a directory containing .contig.fasta files
- **Inside the container:** run `./run_all_sequences.sh <input_folder> <output_folder> [additional_mitofinder_args...]`
- **Outsider the container:** This is the most straightforward method. Just run:
```bash
docker run --privileged -it --rm \
-v /path/to/input:/data/input \
-v /path/to/output:/data/output \
singularity-mitofinder:latest \
./run_all_sequences.sh /data/input /data/output [additional_mitofinder_args...]
```
---

## Notes

1. **Permissions**: Ensure that the user running the container has the necessary permissions to use Docker and access mounted volumes.
2. **Resource Allocation**: For resource-intensive operations, consider adjusting Docker's resource allocation (CPU, memory) via your Docker settings.
3. **Custom Configuration**: If needed, you can modify the Dockerfile to include additional dependencies or customize configurations for your specific workflow.

---

Feel free to submit issues or pull requests for suggestions or improvements!
