{config, lib, options, ...}: let
  l = lib // builtins;
  t = l.types;

  deps = config.deps;

  packageName = config.name;

  title = "Manual for ${packageName}";

  nixosOptionsDoc = deps.nixosOptionsDoc {
    inherit options;
    documentType = "none";
    warningsAreErrors = false;
    markdownByDefault = true;
  };

  rendered = deps.runCommandNoCC "option-doc-${packageName}"
    {
      nativeBuildInputs = [ deps.libxslt.bin deps.pandoc ];
      inputDoc = nixosOptionsDoc.optionsDocBook;
      title = packageName;
      preface = "preface";
    } ''
      xsltproc --stringparam title "$title" \
        -o options.db.xml ${./options.xsl} \
        "$inputDoc"
      mkdir $out
      pandoc --verbose --from docbook --to html options.db.xml >options.html
      cp options.html $out/options.html
    '';

  docs = deps.stdenvNoCC.mkDerivation {
    name = "docs-for-${packageName}";
    nativeBuildInputs = [ deps.mdbook deps.mdbook-linkcheck ];
    src = ./.;
    buildPhase = ''
      runHook preBuild

      substituteInPlace book.toml --replace __TITLE__ "${title}"

      mkdir -p src/options
      for f in ${rendered}/*.html; do
        echo copying $f
        cp "$f" "src/options/$(basename "$f" .html).md"
      done
      mdbook build --dest-dir $TMPDIR/out
      cp -r $TMPDIR/out/html $out

      runHook postBuild
    '';
    dontInstall = true;
  };

in {

  options = {
    public.docs = l.mkOption {
      type = t.package;
      description = "The manual of the package as a website";
      readOnly = true;
    };
  };

  config.deps = {nixpkgs, ...}: l.mapAttrs (_: l.mkOptionDefault) {
    inherit (nixpkgs)
      nixosOptionsDoc
      libxslt
      mdbook
      mdbook-linkcheck
      pandoc
      runCommandNoCC
      stdenvNoCC
      ;
  };

  config.public.docs = docs;
}
