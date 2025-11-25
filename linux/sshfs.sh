#!/bin/bash

sshfs -o password_stdin user@host:/server/path /local/path <<<'password'
