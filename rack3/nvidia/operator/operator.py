# ruff: noqa


def nvidia(deps: list[Resource]) -> list[Resource]:
    ns = Namespace(
        "gpu-ns",
        metadata=ObjectMetaArgs(name="gpu-operator", labels={"pod-security.kubernetes.io/enforce": "privileged"}),
    )
    chart = Chart(
        "gpu-chart",
        namespace=ns.metadata.name,
        chart="gpu-operator",
        repository_opts=RepositoryOptsArgs(repo="https://helm.ngc.nvidia.com/nvidia"),
        value_yaml_files=[pulumi.FileAsset("nvidia/gpu.yml")],
    )
    return [ns, chart]
