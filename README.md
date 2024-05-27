# openingreport-fze2023

存储傅泽同学的研究生论文的开题报告。

## 把大象装进冰箱里分几步？

目前按照笔者理解，“将Substrate移植到rCore中”大概需要这么几步：

1. 剔除Substrate Node Template的死代码，精简之
2. 将精简的Substrate Node Template移植到rCore中
   1. 将不能在no-std环境中运行的crate尽可能替换掉。
   2. 为剩下的不支持no-std环境的crate做适配。
   3. 逐步移植到用户态、验证。
   4. 从内核态逐步移植到内核中。

## 第一步：剔除Substrate Node Template的死代码，精简之

相关的主题词：**死代码探测、死代码移除**

### 基本信息

#### 概念

不同学科领域对死代码的定义也有所不同。

- 在软件工程领域：
  - Brown等人在其[书](https://www.wiley.com/en-us/AntiPatterns%3A+Refactoring+Software%2C+Architectures%2C+and+Projects+in+Crisis-p-9780471197133)中将死代码定义为：在不断变化的软件设计中始终未移除的未使用代码。
  - Mantyla等人[1]认为：死代码就是过去使用过，但目前已不会再被执行的源代码。
  - Wake [2]将未使用的变量、函数参数、类成员属性、类方法和类本身视为死代码。
  - Martin [3]将死代码定义为从未执行过的代码（例如永假if内的语句块），而死函数是永远不会被调用的方法。
- 在程序设计语言领域：
  - 死代码是指其结果从未被使用的计算（例如，在代码中引用的变量，但在运行时实际上不使用）[12]

总结来看，死代码就是完全不参与程序执行过程的代码。在程序执行的过程中找不到他们的踪迹。正因它们不参与程序执行过程，才可以将其剔除。

#### 危害性

[A Multi-Study Investigation into Dead Code | IEEE Journals & Magazine | IEEE Xplore](https://ieeexplore.ieee.org/abstract/document/8370748)从多个角度论述了死代码对软件项目的危害性。主要可以归结为以下几点：

* **令代码更难理解**: 开发者更难理解代码的结构和用意。对于经验较浅的新开发人员，他们可能会误以为死代码是有用的，从而轻则花费不必要的时间弄懂死代码、重则任其累积令代码库的质量越来越差。

* **令代码更难维护**: 让维护工作变得更加复杂，在日常维护或升级迭代时影响开发人员的工作效率、在降低代码质量的同时可能还会引入新的缺陷甚至错误。

* **徒增开发工时**: 开发者花费无用的时间维护死代码或对其进行debug，而这部分工作对项目并无任何帮助。

* **拖慢运行效率**: 虽非总是如此，但死代码有可能拖慢运行效率或徒增内存占用。

* **拉低代码质量**: 死代码越多，可以认为团队的专业性越低，开发标准越宽松。

### 已有技术方案

#### JavaScript的[Tree Shaking](https://developer.mozilla.org/zh-CN/docs/Glossary/Tree_shaking)技术

Tree Shaking通常被认为是JavaScript的专有术语，其高度依赖ES2015标准引入的`import`、`export`模块语法，该概念是随着捆绑器`rollup`逐渐流行起来的。捆绑器的作用是将许多小的代码片段连接起来形成一个更大的源代码文件。因此，为缩减源代码体积、提升代码运行效率、改善可读性，有必要使用某种技术将死代码移除。Tree Shaking正是为此而来。

在一个项目中，有一个入口文件，相当于一棵树的主干。入口文件有很多依赖的模块，相当于树枝。实际情况中，虽然依赖了某个模块，但其实只使用其中的某些功能。通过Tree Shaking，将没有使用的模块摇掉，这样来达到删除无用代码的目的。

**亮点**：

- 只要使用`import`、`export`来导入导出，Tree Shaking即可借此了解哪些模块被使用，哪些没有。
  - 如果使用`import * from xxx`，由于过于宽泛，Tree Shaking不会起作用。

**局限性**：

- **对开发者透明**。也就是说，上述代码精简工作是在捆绑的过程中自动完成，既不会改变源代码也不会给出任何提示，开发者无从知晓哪些代码被移除了。
- **只能删除整个模块**。对于那些被使用但只是部分使用的模块，如只使用其中几个函数的模块，Tree shaking并不能消除不被使用的函数。
- 标记一些函数为“无副作用”的，这样Tree Shaking才能放心地将其删除。也就是说，**无副作用性是开发者手动给出的**。
  - 副作用：一个函数能够在其作用域之外修改数据。

#### PHP Web系统的动态标记法

考虑到PHP编程语言包含许多动态特性，作者团队提出了一种基于动态分析的死代码识别和移除方法。具体来说，首先收集Web系统用到的所有文件，然后为其标注元数据，包含首次/最后使用时间，使用次数等。然后运行Web系统，维护并追踪上述指标的变化。运行系统一段时间以后，即可得知哪个文件是不用的/不常用的。

**亮点：**

1. **投入了实际案例应用**：方法在一个工业规模的Web系统中进行了测试，该系统由Hostnet公司部署，负责托管和市场营销荷兰的".nl"域名。
   1. 在Hostnet的一个主要应用程序中，工程师能够在一天内安全地移除2740个未使用的Aurora文件，这几乎占到了Aurora原始代码库存的30%。
2. **存在工具支持**：开发了两个工具，一个是基于树状图（Tree Map）的Web应用程序，另一个是Eclipse插件，用于可视化展示使用和未使用的文件。它们能帮助工程师可视化动态分析收集到的数据，从而支持他们在移除未使用代码时做出决策。
3. **性能开销**很小：在Aurora子系统中增加的额外分析代码导致的性能开销非常小，95%的情况下页面请求的额外等待时间低于6毫秒，用户几乎没有察觉。

**局限性：**

1. **长时间等待**：为了确定一个文件是否真的不再使用，需要等待相当长的时间来收集足够的数据，这可能影响方法的实用性。
2. **动态系统的不确定性**：与更传统的、单一的和静态的系统中的死代码识别和移除不同，在动态Web应用中，无法事先确定一个文件将来是否会被使用。
3. **需要人工决策**：尽管有工具支持，但最终确定文件是否为死代码并移除它，需要人工决策和领域特定信息。

#### JSNose

JSNose的设计初衷是探测JavaScript项目中的代码异味，死代码检测只是其众多检测目标中的一个。JSNose采用了动态静态结合的方法来检测代码异味。静态分析方面，它分析代码的抽象语法树并遍历之，从而取得关于源代码中所有实体、对象、函数、代码块的信息，并予以记录。动态分析方面，它在浏览器和服务器之间设置了一层代理来拦截并得知JavaScript代码的运行情况，以此确定语句覆盖率（statement coverage），进而确定死代码。

JSNose采用了一种METRIC-BASED的方法来划分各种代码异味。这种方法的宗旨是一张表，规定了“包含某几种指标”的代码异味具体属于哪一种。以死代码举例，它所使用的指标就是两个：EXEC（执行计数）和RCH（可达性）。对某段代码，这两个指标中的任意一个为0，即可认定该段代码中存在死代码的代码异味。

为探测死代码，需要收集执行过程中的追踪信息（execution trace）。JSNose的方案是，一边尽可能长地使用程序，一边用爬虫记录拦截到的JavaScript执行情况。这样一来，它的局限性就不言而喻了：查全率和使用程序的时间和方法正相关，可能会出现假阳性。

#### DUM

文章提出了一种名为DUM（Detecting Unreachable Methods）的**静态**方法，用于检测Java软件中的不可达方法。作者团队对基于图的函数表示方法给出了很高的评价，因此DUM也被设计为：在Java字节码上工作，利用其中的信息将源程序转换为有向图表示（可以理解为方法函数调用图），在这个图中，节点代表方法，边代表方法之间的关系。需要注意的是DUM对待虚拟方法的对策：对于虚拟方法调用，如果某个方法`m`中出现了对**虚拟方法**`e.m'(...)`的调用，则在`m`的节点和所有具有相同函数签名`m'`的方法节点之间添加一条边。建图完成后，通过从一个集合起始节点开始遍历图来识别可达节点，不可达节点即为那些无法从这些起始节点到达的节点。

**亮点：**

- **正确性、完整性和准确性**：通过在四个开源软件上的实验验证了DUM方法的正确性、完整性和准确性。
- **与现有工具比较**：将DUM的结果与JTombstone和Google CodePro AnalytiX等工具进行比较，结果表明DUM在检测不可达方法方面表现更好，假阳性和假阴性率都更低。
- **处理反射和多线程**：DUM能够部分处理Java反射和多线程情形下的不可达方法检测，这是许多静态分析工具的挑战之一。
  - Java的**反射**允许程序在运行时（Runtime）检查、访问和修改它自己的结构和行为。

**局限性：**

- **复杂反射的挑战**：文章指出，Java反射的使用给不可达方法的识别带来了挑战，尽管DUM在处理简单反射应用案例时表现出了准确性。
- **GUI事件处理**：对于由用户动作触发的GUI事件的管理可能会影响不可达方法的识别，DUM在构建图基表示时考虑了这一点，但可能还有改进空间。

### 其他相关工作

#### MIRAI

选择MIRAI有充足的原因。首先，它仍然在维护状态，仓库最后一次更新是在5个月前。虽然不算更新非常频繁，但也比其他最后一次更新在数年前的工具好太多了。其次，它利用MIR而不是LLVM IR进行分析，能够从更高层次获得LLVM IR中没有（或者被曲解）的信息。例如，LLVM IR中没有无符号整数类型，故所有的 `u32`到了LLVM IR中全变成了 `i32`，为分析横添困难。最后，它在上文中提及的函数调用图基准测试中取得了令人瞠目结舌的好成绩，除了涉及条件编译的测试用例只通过了50%以外，其他测试用例均是100%通过，爆杀LLVM  OPT。与Mirai相关的资料链接有这些：

- [MIRAI仓库地址](https://github.com/facebookexperimental/MIRAI)

  - [MIRAI安装指南](https://github.com/facebookexperimental/MIRAI/blob/main/documentation/InstallationGuide.md)
  - [MIRAI函数调用图子功能叙述](https://github.com/facebookexperimental/MIRAI/blob/main/documentation/CallGraph.md)
- [在基准测试中测试Mirai-CGG](https://github.com/ktrianta/rust-callgraph-benchmark/tree/master/evaluations/mirai-cgg)



在安装和使用MIRAI的过程中，有几点需要注意：

- 编译MIRAI时，cargo会使用其仓库中 `rust-toolchain.toml`所指定的 `nightly-2023-09-10`进行编译。笔者利用更新的nightly版本尝试编译未能通过。

下面讨论使用MIRAI进行函数调用图生成的方法。本节内容基于[MIRAI函数调用图子功能叙述](https://github.com/facebookexperimental/MIRAI/blob/main/documentation/CallGraph.md)，结合笔者实操进行叙述。

首先cd到待分析的rust crate根目录中（即该crate的 `Cargo.toml`所在的目录），然后运行 `cargo mirai`进行分析。此时大概率会报错，报错信息类似于 `error while loading shared libraries: librustc_driver-8e42xxxx.so`。这是因为MIRAI对rust版本的要求十分严格，需要编译MIRAI和编译待分析crate的rust版本一致。解决方案也较为简单，指定待分析crate使用 `nightly-2023-09-10`进行编译即可。虽然可以通过给待分析crate增添 `rust-toolchain.toml`来完成、或者通过在待分析crate根目录中运行 `rustup override set nightly-2023-09-10`来完成，笔者仍然推荐直接使用 `rustup default nightly-2023-09-10-x86_64-unknown-linux-gnu`将该版本nightly设置为全局版本，因为在下一步生成调用图时可能会出问题（指编译卡住不动，RAM占用率飙升）。

想要生成函数调用图，还需设置 `MIRAI_FLAGS`环境变量。如此设置即可：

```bash
export MIRAI_FLAGS="--call_graph_config $(pwd)/cg-config.json"
```

一定一定要记得加 `export`不然MIRAI会探测不到这个环境变量。`$(pwd)/cg-config.json`表示生成调用图所使用的配置文件，本次生成使用的文件长这样：

```json
{
    "call_sites_output_path": "./call-sites.json",
    "dot_output_path": "./graph.dot",
    "reductions": [],
    "included_crates": [],
    "datalog_config": {
        "ddlog_output_path": "./graph.dat",
        "type_map_output_path": "./types.json",
        "datalog_backend": "DifferentialDatalog"
    }
}
```

其中字段的含义请参见[函数调用图字段含义](https://github.com/facebookexperimental/MIRAI/blob/main/documentation/CallGraph.md#Configuration)。

设置好 `MIRAI_FLAGS`并运行 `cargo mirai`之后，一个名为 `graph.dot`的文件将会在待分析crate的根目录中生成，可以使用Graphviz工具进行可视化了：

```bash
cat graph.dot | dot -Tsvg
```

MIRAI的配置文件有许多可自定义的选项，通过配置它们可以从不同角度获得许多很有用的信息。

#### call_sites_output_path

JSON格式的文件。

- `files`：数组，包含调用图中涉及到的源文件路径。

  ```json
  [
      "src/main.rs",
      "/rustc/8ed4537d7c238eb77509d82445cf1cb861a3b5ff/library/core/src/fmt/rt.rs",
      "src/funcs.rs",
      ...
  ]
  ```

- `callable`：数组，每一项的内容如下。

  ```json
  [
      {
          "name": "/example_crate/main()->()",
          // 函数定义的源文件在 files 数组中的索引
          "file_index": 0,
          // 在上述源文件中定义的行号
          "first_line": 4,
          // 意义暂时不明
          "local": true
      },
      ...
  ]
  ```

- `calls`：**重头戏！**数组，每一项都是一个五元组。

  ```json
  [
      [
          0, // source location源地址, files数组中的下标
          5, // 行号
          5, // 列号
          0, // caller, callables数组中的下标 
          1 // callee, callables数组中的下标 
      ],
      ...
  ]
  ```

#### reductions

数组，可能包含以下选项，可以裁剪调用图的内容。

- `{"Slice": "函数名字"}`：MIRAI将返回以这个函数为树根的子调用图。
- `"Fold"`：和下文`include_crates`配合使用，可以将`include_crates`之外的调用情况隐藏起来。举例：`include_crates = ["rust-pg"]`，那么`rust-pg`项目中调用的`/std/std::io::_print`函数就不会画在图里，但是在`callables`字段中还是能看到它们。
- `"Deduplicate"`：指定此字段之后，调用图中的每个函数之间最多仅会有一条边相连，更加简化从而更好看。
- `"Clean"`：将孤儿节点去除。

## 第二步：将精简的Substrate Node Template移植到rCore中

相关的主题词：**操作系统内核、往内核中增加新的功能、系统调用**

### no-std环境下的Rust

[Rust for Embedded Systems: Current State, Challenges and Open Problems (arxiv.org)](https://arxiv.org/abs/2311.05063)一文介绍了Rust在嵌入式开发领域的现状，并着重介绍了现阶段存在的问题。它通过采访、问卷等方式，收集获得了以下问题：

- 社区支持问题：许多开发者觉得缺少文档（尤其是例子）难以开发
- 依赖项兼容性问题：x86架构平台上的crate依赖于其他库或框架，而这些库或框架在嵌入式设备上不可用/不兼容
