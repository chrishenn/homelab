# ruff: noqa


def nvidia(deps: list[Resource]) -> list[Resource]:
    ...
    chart = Chart(
        "dra-chart",
        namespace="kube-system",
        chart="nvidia-dra-driver-gpu",
        repository_opts=RepositoryOptsArgs(repo="https://helm.ngc.nvidia.com/nvidia"),
        value_yaml_files=[pulumi.FileAsset("nvidia/dra.yml")],
    )
    return [chart]
