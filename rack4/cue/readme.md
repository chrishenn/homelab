# cue

print to stdout

```bash
cue export -s --out yaml ./...
```

# notes

On the one hand, there's tons of language-like features for typing, restricting, and validating configs. And the way the
language unifies constraints with data is pretty cool/concise.

On the other hand, it's not too far from just using a real language to do some of that validation. Granted, you can
split different values and validation constraints across various cue files - is that really an advantage?

The more obvious downside is that you're adding an additional obfuscating step between the text checked into version
control and the text that is consumed by the tool (k8s, docker compose, etc). I imagine that cuelang argues
that the additional automatic validation will catch bugs before they make it into the final exported text.

---

On a more granular note:

My first stab at some simple conditional logic was not the most concise. Probably there are language features I've not
learned yet that could clean it up.

Using yaml's native syntax to define and reuse a map in multiple places does not automatically import into cuelang 1:1.
If I want to define both data and schema in cuelang, then I would need to manually translate a yaml map reference (? not
sure what it's called) into a cuelang object.

Tried to set a flag on a service like "_db" or "_redis" that would trigger adding a service like "service_db" with the
standard database or redis template. However, I couldn't figure out how to construct that map using the service's name,
and then add the resulting map into the "services" map one level higher.
