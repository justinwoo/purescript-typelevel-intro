default:
	nix-shell --run 'make slides'
slides:
	pandoc -t beamer slides.md -o slides.pdf
watch:
	nix-shell --run 'watchexec -e md make'
repl:
	nix repl '<nixpkgs>'
