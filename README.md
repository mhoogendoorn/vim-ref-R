# vim-ref-R
A [vim-ref](https://github.com/thinca/vim-ref) source for R documentation.

## Why?
Mostly as an exercise.
For general usage [vim-R-plugin](https://github.com/jcfaria/Vim-R-plugin) is probably better (and this uses its rdoc highlighting).

## Usage

```vim
:Ref R rnorm
```

## Problems
It will not show help for functions from packages that are not loaded when `Rscript` is run.
Doesn't do completions, so no point in using it as a Unite source.

