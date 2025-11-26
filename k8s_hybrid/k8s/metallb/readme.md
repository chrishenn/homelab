Uh-oh. Metallb is only compatible with calico BGP, which we can't use because of our windows node.

---

in the technotim ansible k3s deployment, we have:

metallb_type: native
metallb_mode: layer2

Set image versions in manifest for metallb-{{ metal_lb_type }}
metallb/speaker:{{ metal_lb_controller_tag_version }}

metal_lb_ip_range: 192.168.30.80-192.168.30.90

metal_lb_speaker_tag_version: v0.15.2
metal_lb_controller_tag_version: v0.15.2
