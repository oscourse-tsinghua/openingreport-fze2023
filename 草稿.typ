// 首行缩进
#let blank = par()[#text(size: 0.4em)[#h(0em)]]
#set par(first-line-indent: 2em)
#show heading: name => {
  name
  blank
}
#show list: name => {
  name
  blank
}

#show link: name => strong()[#underline()[#name]]
// 设置标题序号格式
#set heading(numbering: "1.")
// 文档标题
#align(center)[
  #block(text(weight: 700, 1.75em, "开题报告"))
  #block(text(weight: 700, 1em, "计算机学院2023级数硕士9班 3220231370 傅泽"))
  #v(2em, weak: true)
]
// 双栏布局
// #show: columns.with(2, gutter: 1.6em)

= 选题依据

== 选题背景及意义

近年来，越来越多的开发者为rust编程语言的高内存安全性和高效率性所吸引，愿意使用之以开发自己的操作系统及配套的软件生态环境。然而，操作系统开发的关键点之一在于丰富的软件生态环境，这正是新兴操作系统所欠缺的。鉴于Linux操作系统的生态环境相对成熟性，将Linux应用程序移植到生态环境尚不成熟的的新兴操作系统中成为了快速拓展新兴操作系统软件生态环境的方案之一。移植软件，首先需要理解移植对象的业务逻辑。然而，各种已有软件中广泛存在的代码异味，尤其是死代码，使得理解它们的业务逻辑变得更加困难。

目前，已有不少工作针对部分主流编程语言提出了死代码移除的技术方案。然而，作为新兴系统级编程语言的rust编程语言却缺少类似的技术方案。目前，rust语言已被广泛应用于操作系统、嵌入式设备等领域的开发工作。这种工作代码量巨大，且需要进行反复的迭代和尝试，从而更容易累积死代码。然而，无论是从代码质量和可维护性的角度出发，还是从嵌入式设备上装载的、有限的存储空间的角度出发，死代码移除之于rust软件项目的重要性只增不减。

本选题提出一种基于函数调用图进行死代码探测的技术方案，帮助开发者更高效地移除死代码，在简化软件业务逻辑理解的同时，降低代码库体积，提升软件运行效率；为验证这一方案的可行性，本选题还将以实际rust软件项目为对象进行死代码移除，并移植到真实操作系统中，使之成为顺应Web 3.0时代潮流的区块链操作系统。

== 国内外研究现状

=== 死代码的概念

死代码是一种广泛存在于软件源代码中的代码异味。不同学派对死代码的定义不尽相同。Brown等人将死代码定义为在不断变化的软件设计中始终未移除的未使用代码@BrownBook 。Mantyla等人认为：死代码就是过去使用过，但目前已不会再被执行的源代码@Mantyla2003 。Wake将未使用的变量、函数参数、类成员属性、类方法和类本身视为死代码@WakeBook 。Martin将死代码定义为从未执行过的代码（例如永假if内的语句块），而死函数是永远不会被调用的方法@MartinBook 。而在程序设计语言领域，死代码是指其结果从未被使用的计算（例如，在代码中引用的变量，但在运行时实际上不使用）@CodeCompaction 。虽定义不同，其本质并无二样，即死代码是在程序运行过程中永不可能被执行的部分。

虽然死代码并不会被执行，但它们对软件开发与维护仍具有负面影响，主要可以归结为以下几点@MultiStudy：

- 令代码更难理解: 开发者更难理解代码的结构和用意@BetterUnderstanding @MetricsUnderstanding 。对于经验尚不丰富的新开发人员，他们可能会误以为死代码是有用的，从而轻则花费不必要的时间弄懂死代码、重则任其累积令代码库的质量越来越差。

- 令代码更难维护：让维护工作变得更加复杂，在日常维护或升级迭代时影响开发人员的工作效率、在降低代码质量的同时可能还会引入新的缺陷甚至错误@SoftwareAgeing 。

- 徒增开发工时：开发者花费无用的时间维护死代码或对其进行debug，而这部分工作对项目并无任何帮助。

- 降低运行效率：虽非总是如此，但死代码有可能降低软件运行效率或徒增内存占用。

=== 死代码探测与移除技术

目前，针对不同编程语言的死代码探测及移除技术不断涌现，其中较具代表性的有JavaScript的Tree Shaking技术方案，PHP的Web系统的动态标记技术方案和Java的DUM技术方案。

Tree Shaking技术方案依赖ES2015标准引入的`import`、`export`模块语法进行死代码移除。它通过分析依赖关系，确定未使用的模块并在最终生成的代码中将它们剔除。然而其简单的技术原理与思想也带来了局限性：它只能以模块为单位，而不能以模块中具体的功能为单位进行移除，导致生成的源代码体积仍然过大；另外，该过程对开发者透明，开发者无从知晓哪些模块被删除，因此无法辅助开发者主动提高代码质量。

PHP的Web系统动态标记技术方案@PHPWebSystem 首先收集Web系统用到的所有文件，然后为其标注元数据，包含首次、最后使用时间，使用次数等。然后运行该Web系统，利用动态分析技术维护并追踪上述指标的变化@DynAnalysis 。运行系统一段时间以后查阅元数据，即可得知哪个文件是冗余或不常用的。该方案在Hostnet工业规模中进行了测试，并安全高效地移除了30%的原始代码库中的死代码。虽然如此，动态分析技术的特性决定了运行该技术方案需要覆盖率足够广、持续时间足够长的测试以减少漏检；且最终结果需要人工决策，无法实现完全自动化。同时，它也和Tree Shaking一样，只能实现文件级的，粒度较大的死代码移除。

Java的DUM技术方案提出了一种基于静态分析的技术方案，用于探测Java桌面软件中的不可达方法@DUM 。它被设计为在Java字节码上工作，利用其中的信息将源程序转换为有向图表示@GraphBuilding 。建图完成后，通过从一个起始节点开始遍历之来识别可达节点，其余即视为不可达节点（代表不可达方法）。与JTombstone、Google CodePro AnalytiX等行业已有工具比较，DUM表现出了更高的查准率。与前两种技术方案相比，DUM的分析粒度可达方法级别，远远细于Tree Shaking的模块级别和PHP动态标记技术的文件级别，使之能够移除尽可能多的死代码，最大地减轻开发者理解已有软件业务逻辑的心智负担，提升软件代码库质量及其运行效率。

综上所述，死代码对软件项目的负面影响使其成为有必要移除的代码异味，目前较有代表性的技术方案均有其优越性及局限性，在这其中，基于函数调用图的静态分析方法能够实现细粒度的死代码探测，其良好的效果与函数调用图在主流编程语言上的广泛性使得它成为在rust编程语言上实现死代码探测的理想途径。

=== CG-RTL函数调用图生成工具

编译型程序设计语言的编译工具链在将源代码编译为目标平台的二进制可执行文件时，往往会选择先将源代码编译为某种形式的中间表示（IR），再将中间表示编译为目标平台的机器代码。文献 @cg_rtl 提出一种基于寄存器传送语言（Register Transfer Language，RTL）中间表示的分析方法，从GCC编译器输出的RTL中间表示中，利用字符串处理提取当前软件包中的函数定义、函数调用信息，与其他软件包的上述信息进行整合，最终绘制成一张函数调用有向图。在此基础上，研究团队又提出了能够处理动态函数调用的DCG-RTL @dcg_rtl 和基于数据库的函数调用图生成工具 @dbcg_rtl 。

CG-RTL解决了已有工具需要基础知识、产生过量冗余信息、和编译环境耦合度过高的问题。虽其仅适用于C语言的RTL中间表示分析，但其利用中间表示进行逐模块分析的方法仍然值得借鉴。

=== rust的中间表示

在部分语言中，为方便从不同的角度进行全面完善的检查，一些语言使用数种不同层级的中间表示，待上层级中间表示通过检查后，再将其编译为下一层级的中间表示，运行下一步的检查，如此逐层降低层级（Lowering），直至获得最后的机器码。这些中间表示从不同角度呈现了不同的信息，有利于软件开发者开发外部工具对其进行诸如静态检查等操作。rust程序设计语言亦采用了这种多层级中间表示的思路。按层级由高到低，rust一共使用了如下四种中间表示：

1. 高层级中间表示（HIR）：HIR是rust中最高层级的中间表示，由对源代码进行语法解析、宏展开等处理之后的抽象语法树转换而来。其形式和rust源代码尚有相似之处，但将一些语法糖展开为了更易于分析的形式，例如`for`循环将被展开为`loop`循环等。但由于此时rustc编译器尚未进行类型检查，因此HIR中的类型信息较为模糊，不适合作为静态分析工具的输入。
2. 带类型的高层级中间表示（THIR）：该中间表示是由HIR在完成类型检查后降低层级而来，主要用于枚举穷尽性检查、不安全行为检查和下一层中间表示的构造。和HIR相比，THIR最大的不同在于诸如`struct`和`trait`等结构将不会在THIR中出现，因为THIR仅保留了源代码中可执行的部分，例如定义的普通函数以及`impl`块中定义的关联函数、方法等。由于具有上述“仅保留可执行部分”以及结构比HIR更简洁的特点，THIR非常适合用于分析rust crate中的函数定义信息。
3. 中层级中间表示（MIR）：这种中间表示于RFC 1211中初次引入#footnote[https://blog.rust-lang.org/2016/04/19/MIR.html]，用于控制流相关的安全检查，例如借用检查器。它进一步将一些语法糖展开，引入了在rust源代码中不可能出现的语句，同时也会执行控制流分析。由于rustc提供了一组不稳定的API接口用于和MIR交互，MIR成为了诸多外部工具处理rust程序代码的不二选择，如MIRChecker @MirChecker 、Kani @Kani 等均采用MIR作为其分析对象。

=== Prazi与函数调用依赖关系网络

随着托管平台投毒等安全威胁的出现，基于包依赖关系网络（Package Dependency Network，PDN）的大粒度分析已不能满足当下软件安全分析的需求。因此，Joseph Hejderup等人提出了一种全新的依赖关系网络：函数调用依赖关系网络（Call-graph Dependency Network，CDN） @Prazi ，并利用之进行更细粒度的分析。为获得函数调用依赖关系网络，他们开发了Prazi分析器。这是一款基于MIR中间表示、利用Docker的虚拟环境进行软件包编译、借助rust-callgraphs工具生成函数调用图的分析工具，能够针对一个crate生成它的函数调用依赖关系网络。

为证明该方案的可用性，作者团队为crates.io上的所有crate都使用prazi进行了分析，并通过分析统计数据得出了有价值的结论。在crates.io托管的所有软件包中，50%的函数调用是在调用外部依赖项中的函数。不仅如此，虽然一个crate在其78.8%的直接依赖项中至少会调用一个函数，但在其传递依赖项中至少调用一个函数的概率却锐减至40%，这表明软件包的所有传递依赖项中有一半以上可能没有被调用。

虽然受制于rust编译器提供的MIR编程接口的不稳定性，Prazi分析器已无法使用，但其证明了在rust项目上生成函数调用图并进一步分析的技术可行性；同时，传递依赖项的函数调用率锐减也反映了rust软件项目中死代码存在的广泛性，进一步证明了选题的意义。

=== MIRAI

MIRAI由来自Facebook的技术团队开发，是一款工作在rust编程语言的中层中间表示（MIR）上的静态分析工具#footnote[https://github.com/facebookexperimental/MIRAI]。与追求创新性的学术用途原型工具不同，MIRAI追求在实际工业生产环境中的实用性。其宗旨是在尽可能低的假阳率下定位存在异味的rust代码，并给出切实可行的修改建议。

MIRAI包含许多功能，其中的函数调用关系生成功能（下简称为MIRAI-CGG）十分强大。MIRAI-CGG支持为指定crate生成函数调用关系信息，这些信息不仅可以输出为`.dot`文件，供Graphviz工具绘制为矢量图，还能输出`JSON`格式的函数调用位置（callsite）信息，包含发生调用的源代码文件虚拟路径、行号、列号，以及调用者（called）与被调用者（callee）的信息，十分全面。然而，其低假阳率的目标并不完全适用于分析死代码。经过试验发现，MIRAI对函数调用情况存在漏报，开发者若完全按照MIRAI的输出进行死代码移除，有概率将具有实际作用的代码移除导致软件功能缺失甚至编译不通过。因此，有必要对MIRAI进行必要的修改，降低其漏报率，方能用于死代码移除。

=== Substrate区块链

Substrate由以太坊项目的联合创始人Gavin Wood率领Parity团队开发，是一个基于rust的开源区块链框架。它对于多链结构提供了较好的支持，能够克服传统单链区块链在一条链上保有大量用户、存储大量信息，导致运行效率降低的问题，且针对多链间通信提出了一套解决方案。不仅如此，高度可定制的灵活模块化设计模式，使得Substrate能够以功能模块（称之为pallet）为单位进行组件增删，令开发者得以将Substrate打造成最契合他们需求的区块链。

Substrate完全基于rust编程语言开发，其代码库大小适中，既能体现本选题提出的死代码探测方案的泛用性，又不至于因代码量过大导致分析过分繁杂。此外，区块链技术与操作系统内核的融合领域的研究工作较少，本课题亦可借此机会探索区块链技术与操作系统融合的形式，探究此举对操作系统技术发展的意义。

= 研究内容

// 调研A，利用B，实现C，达成D效果
本选题提出一种基于函数调用图进行死代码探测的技术方案，帮助开发者更高效地移除死代码；为验证这一方案的可行性，本选题还将以Substrate区块链项目为对象进行死代码移除，并移植到rCore操作系统中。工作大致可分为两部分：

- 改进并利用MIRAI获取rust软件项目的函数调用图，采用基于函数调用图的方法探测死代码并标记之，以在简化软件业务逻辑理解的同时，降低代码库体积，提升软件运行效率

- 将经过代码裁剪的Substrate移植到教学操作系统rCore中，使之成为顺应Web 3.0时代潮流的区块链操作系统。

= 研究方案

== 死代码探测实施方案

目前，市面上尚无针对rust编程语言进行死代码探测的工具。故本选题计划以MIRAI静态分析为基底，以死代码探测为目标进行修改，去除不必要的功能并完善函数调用图生成功能，以构造基于函数调用图的死代码探测技术方案。为验证该方案的可行性，取Substrate全节点客户端作为待分析项目，探测并移除其死代码，获得精简的Substrate全节点客户端。

== 跨操作系统移植实施方案

考虑到rCore操作系统同样以rust写成，且结构简单利于分析，故以rCore为移植目标平台，对精简的Substrate全节点客户端开展移植工作。这包含替换或重写不适配rCore运行环境的依赖项，并为rCore实现必须的系统调用。最终，将rCore打造成包含部分区块链特性的区块链操作系统。

== 实验方案

= 预期研究成果

预期硕士学位论文一篇，死代码移除技术方案一套，带有部分区块链功能特性的操作系统软件一套。

= 本课题创新点

本选题的创新点有：一是为rust编程语言实现了一种基于函数调用图的死代码探测技术；二是将经过死代码移除处理后的软件移植到另一操作系统中，以证明该技术对于移植工作的便利性贡献度。

#bibliography("refs.bib", title: "参考文献")

