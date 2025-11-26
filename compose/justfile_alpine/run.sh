#!/bin/bash

sudo apk add just libc6-compat

just --justfile /scripts/github/justfile run
