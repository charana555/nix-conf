{ inputs, lib }:
let
  openagentsControl = inputs.openagents-control;
  registry = builtins.fromJSON (builtins.readFile "${openagentsControl}/registry.json");
  profileComponents = registry.profiles.developer.components or [ ];

  registryKey =
    type:
    if type == "config" then
      "config"
    else if lib.hasSuffix "s" type then
      type
    else
      type + "s";

  wildcardPrefix = type: id: ".opencode/${type}/${lib.removeSuffix "/*" id}/";

  resolveSpec =
    spec:
    let
      parts = lib.splitString ":" spec;
      type = lib.elemAt parts 0;
      id = lib.elemAt parts 1;
      components = registry.components.${registryKey type} or [ ];
    in
    if builtins.length parts != 2 then
      [ ]
    else if lib.hasSuffix "/*" id then
      lib.filter (component: lib.hasPrefix (wildcardPrefix type id) (component.path or "")) components
    else
      lib.filter (component: component.id == id || lib.elem id (component.aliases or [ ])) components;

  componentPaths =
    component:
    lib.unique (
      lib.filter (path: lib.hasPrefix ".opencode/" path) ([ component.path ] ++ (component.files or [ ]))
    );

  componentFiles =
    component:
    map (path: {
      name = "opencode/${lib.removePrefix ".opencode/" path}";
      value.source = "${openagentsControl}/${path}";
    }) (componentPaths component);

  collectSpecs =
    seen: pending:
    if pending == [ ] then
      seen
    else
      let
        spec = builtins.head pending;
        rest = builtins.tail pending;
      in
      if lib.elem spec seen then
        collectSpecs seen rest
      else
        let
          components = resolveSpec spec;
          dependencies = lib.concatMap (component: component.dependencies or [ ]) components;
        in
        collectSpecs (seen ++ [ spec ]) (rest ++ dependencies);

  components = lib.concatMap resolveSpec (collectSpecs [ ] profileComponents);
in
lib.listToAttrs (lib.concatMap componentFiles components)
