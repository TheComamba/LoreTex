[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md) 

# LoreTex

Have you ever struggled to keep your adventure notes organised? Did you copy and paste parts of your lore to different adventures set in the same world and then they ran out of sync? Do you wish to give your players an up-to-date handout but not reveal your secret details?

LoreTex may not be *the* answer to these problems, but it is *my* answer. It is an extension to the Tex language for compiling pdf documents, providing an interface to define characters, places and more, and then generate a glossary containing those entities that are relevant to your story.

## Setup

### Prerequisites

LoreTex assumes that you have the LuaLaTex compiler installed.

All required Tex packages are included at the beginning of main.tex. Currently, these are luacode and nameref.

### Installation [Outdated!!!]

Clone this git repository to some place on your computer:

```bash
git clone https://github.com/TheComamba/LoreTex.git
```

Alternatively copy the contents of this repository to some place on your computer.

LoreTex uses the Lua scripting language, and can thus only be compiled using LuaLaTex. It further needs to load a library, which due to security reasons is only possible in shell-escape mode. Hence, to compile from a terminal you need to call:

```bash
lualatex -shell-escape <your tex document>
```

If you're running from a GUI that supports ["magic comments"/"advanced headers"](https://texstudio-org.github.io/advanced.html#advanced-header-usage), you can add the line

```bash
% !TeX TXS-program:compile = txs:///lualatex/{%.tex} -shell-escape "%.tex"
```

to your document.

(Note that this contains a bit of a hack, see [this discussion](https://github.com/texstudio-org/texstudio/discussions/3062).)

__A note on security:__

In principle, you could set your default compiler to the value provided above. Do not do this! This allows the execution of basically arbitrary code once you hit compile.

### Usage

The tex file using LoreTex needs to be told where to find main.tex:

```latex
\documentclass{book/memoir}

...

\input{some/relative/path/to/main.tex}
\loadLuacode{some/relative/path/to/}

...

\begin{document}

```

A good place to start is the tutorials folder.

## Contributing

Merge requests are welcome.

Please follow the gitflow naming convention of prefixing branches with "bugfix/" or "feature/". Currently I see no reason for a separate develop branch.

For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update the tests as appropriate.

Criticism of the coding style is very welcome. I find it tough to write clean code in Lua, and I am eager to improve.

And, of course, you are asked to comply with the code of conduct.

## License

This software is distributed under the [MIT](https://choosealicense.com/licenses/mit/) license. In a nutshell this means that all code is made public, and you are free to use it without any charge.