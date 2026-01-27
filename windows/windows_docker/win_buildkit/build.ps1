function build_image {
    buildctl build `
        --output type=image,name=192.168.1.11:5000/chocotools-img:latest,registry.insecure=true,push=true `
        --export-cache type=registry,ref=192.168.1.11:5000/chocotools-img,registry.insecure=true,mode=max,push=true `
        --import-cache type=registry,ref=192.168.1.11:5000/chocotools-img,registry.insecure=true `
        --progress plain `
        --frontend=dockerfile.v0  `
        --local context=. `
        --local dockerfile=.
}

function build_tarball {
    buildctl build `
        --output type=docker,dest=chocotools-file.tgz,name=192.168.1.11:5000/chocotools-file,registry.insecure=true,push=true `
        --export-cache type=registry,ref=192.168.1.11:5000/chocotools-file,registry.insecure=true,mode=max,push=true `
        --import-cache type=registry,ref=192.168.1.11:5000/chocotools-file,registry.insecure=true `
        --progress plain `
        --frontend=dockerfile.v0  `
        --local context=. `
        --local dockerfile=.
}

build_tarball
