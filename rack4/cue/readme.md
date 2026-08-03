# cue

Converting a small sampling of the rack4 docker compose yaml files into cuelang, to see what it would be like. 

So far,
it looks like the line count of most files can be cut nearly in half. Especially the very boilerplate services, like
my postgres and valkey/redis services, can be deduplicated with global cuelang objects. There are
evident advantages from explicit type and value restrictions. Pretty neat.

---

# usage

export all to stdout 

```bash
cue export -s --out yaml ./...
```

---

# notes

On the one hand, there's tons of language-like features for typing, restricting, and validating configs. And the way the
language unifies constraints with data is pretty cool/concise.

On the other hand, it's not too far from just using a real language to do some of that validation. Granted, you can
split different values and validation constraints across various cue files - is that really an advantage?

The more obvious downside is that you're adding an additional obfuscating step between the text checked into version
control and the text that is consumed by the tool (k8s, protobuf, docker compose, etc). I imagine that cuelang argues
the additional automatic validation will catch bugs before they make it into the final exported text.

More granular notes:

My first stab at some simple conditional logic was not the most concise. Probably there are language features I've not
learned yet that could clean it up. Update: this was the case, yes.

Using yaml's native syntax to define and reuse a map in multiple places does not automatically import into cuelang 1:1.
If I want to define both data and schema in cuelang, then I would need to manually translate a yaml map reference (? not
sure what it's called) into a cuelang object.

Tried to set a flag on a service like "_db" or "_redis" that would trigger adding a service like "service_db" with the
standard database or redis template. However, I couldn't figure out how to construct that map using the service's name,
and then add the resulting map into the "services" map one level higher.
