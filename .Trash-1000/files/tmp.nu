do { 
    nom build .#nixosConfigurations.tabula.config.system.build.toplevel --show-trace 
} | complete
