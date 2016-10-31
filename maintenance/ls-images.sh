#!/usr/bin/env bash

# Utility script that will list Docker images in the following format:
# Name:tag | Image ID | Size | Number of layers

# Copyright 2016 Filip Božanić Dimovski <dimfilip20@gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Only superuser or members of the "docker" group can use this tool.
if [ $EUID != 0 ] && ! id -Gn 2>/dev/null | grep --quiet '\bdocker\b'; then
    echo "[$0] must be run as superuser (root), or you must be a member of the \"docker\" group."
    exit 1
fi

# Do not continue if Docker is not available.
if ! which docker 1>/dev/null; then
    echo "Docker cannot be found. This tool reqires Docker to run."
    exit 2
fi

# Get list of all Docker images' names with tags.
# There can be multiple images with the same name, but different tags!
docker_image_names=(`docker images --format="{{.Repository}}:{{.Tag}}" | sort`)

# Do the magic - "docker images" for formatted output, "docker history"
# to count the number of layers. :)
for i in "${docker_image_names[@]}"; do
    docker images $i --format="{{.Repository}}:{{.Tag}} | {{.ID}} | {{.Size}}" | tr -d "\n"
    echo -n " | "
    docker history $i 2>/dev/null | sed -n '1!p' | wc -l
done
