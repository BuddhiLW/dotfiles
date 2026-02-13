
```
Claude.el is only working properly on lazy load; when I run a command like `M-x claude-mode`, then `M-x claude-code-run` starts working
  better (using `eat` default etc). If I don't issue `claude-mode` beforehand, `claude-code-run` gives the following error:
  `claude-code-run: Symbol’s function definition is void: claude-code-vterm-mode` 
```

```
Yes, we will create a git project and verison it, from start. Use vibe kanban to manage this project steps and tasks. Your idea is great
 of shelling of with `bb`. I want the project to be hooked to `clojure-mcp` (to develop the mcp project itself). We have other
`clojure-mcp` setups for clojure projects already. Insipire and learn from them (in other to set it up)
``` 

```
Can you use the clojure-written mcp's clojure-mcp itself too? So you can edit the emacs-mcp project (written in clojure) with a
  clojure-mcp? (bonus: how can we talk a this meta-level with clear language? maybe use some general semantics principle there?)
```

```
 Can the "marriage" between dev-tools clojure-mcp and the emacs-mcp be suittly used? maybe editing with one, and showing the edits in the
  buffer in real time, etc. Maybe you even can think of some possible interactions that would be amazing, from a developer perspective.
```

```
Create an emacs package with bindings useful for our emacs-mcp. an `emacs-mcp.el` that will serve to help you with meta-powers. And to be
  extensible with user's unique workflows. It should probably use some king of memory etc. What do you think of this Idea?
```

```
 Add a watcher internal capabities for logs so you can consume that `REPL` experience
  from interacting with emacs. Like monitoring *messages* and other relevant buffers.
  Note this and add to tasks etc
``` 
