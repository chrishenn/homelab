# traefik

sub-subdomains:

https://community.traefik.io/t/sub-level-subdomains-not-working/23494/3

I would split it:

    domains:
      - main: "{{ domain_name }}"
        sans:
          - "*.{{ domain_name }}"
      - main: "shop.{{ domain_name }}"
        sans:
          - "*.shop.{{ domain_name }}"

And make sure `shop.` is explicitly registered as sub-domain with your DNS provider.
