# zig-htmx-tailwind-example
[![zig version](https://img.shields.io/badge/0.13.0-orange?style=flat&logo=zig&label=Zig&color=%23eba742)](https://ziglang.org/download/)
[![reference Zig](https://img.shields.io/badge/deps%20-2-orange?color=%23eba742)](https://github.com/dgv/zig-htmx-tailwind-example/blob/main/build.zig.zon)
[![htmx version](https://img.shields.io/badge/2.0.2-blue?style=flat&logo=htmx&label=htmx&color=%233366cc)](https://github.com/bigskysoftware/htmx/releases)
[![build](https://github.com/dgv/zig-htmx-tailwind-example/actions/workflows/build.yml/badge.svg)](https://github.com/dgv/zig-htmx-tailwind-example/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![screenshot](https://github.com/dgv/zig-htmx-tailwind-example/blob/main/screenshot.png)

Example CRUD app written in Zig + HTMX + Tailwind CSS

This project implements a pure dynamic web app with SPA-like features but without heavy complex Javascript or frameworks to keep up with. Just HTML/CSS + Zig ⚡

### Usage

```bash
# Clone the repo
$ git clone https://github.com/dgv/zig-htmx-tailwind-example
$ cd zig-htmx-tailwind-example

# Run the server
$ zig build run

# Build the binary (default: ./zig-out/bin/zig-htmx-tailwind-example)
$ zig build
```

**Environmental Variables**
```
ADDR Binding Address (default: 127.0.0.1)
PORT Binding Port (default: 3000)
```

### Dockerfile

I provide this just to easily deploy on a local server.

```bash shell
$ docker build -t zig-htmx-tailwind-example .
$ docker run -p 3000:3000 zig-htmx-tailwind-example
```

### Tailwind

You can use [tailwindcss cli](https://tailwindcss.com/docs/installation) to regenerate the css asset:
```bash
$ tailwindcss -i css/input.css -o css/output.css --minify
```
