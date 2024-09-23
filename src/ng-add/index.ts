import { Rule, SchematicContext, Tree } from '@angular-devkit/schematics';
import { NodePackageInstallTask } from '@angular-devkit/schematics/tasks';

export function ngAdd(): Rule {
  return (tree: Tree, context: SchematicContext) => {
    // 这里可以添加你想要的修改逻辑
    const packageJsonPath = '/package.json';
    if (tree.exists(packageJsonPath)) {
      const packageJson = JSON.parse(tree.read(packageJsonPath)!.toString('utf-8'));
      packageJson.scripts['new-script'] = 'echo "Hello, World!"';
      tree.overwrite(packageJsonPath, JSON.stringify(packageJson, null, 2));
    }

    // 安装新的依赖
    context.addTask(new NodePackageInstallTask());

    return tree;
  };
}
