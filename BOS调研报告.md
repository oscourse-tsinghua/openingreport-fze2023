# 已有的BOS

## 现状

转了一圈之后发现，网络上对于“Blockchain OS”的定义非常宽泛，许多文章认为所有能跑DApp的软件平台都可以叫Blockchain OS（下称BOS），导致搜索结果五花八门，甚至搜到了能在Windows或Linux上直接跑的"BOS"，实际上它的本质就是个类似于go-ethereum的客户端罢了。

## 网络操作系统

[What is a Network Operating System? - GeeksforGeeks](https://www.geeksforgeeks.org/what-is-a-network-operating-system/)

BOS常常被视为一种网络操作系统（NOS）。关于NOS的定义如下：

> A network operating system(NOS) is software that connects multiple devices and computers on the network and allows them to share resources on the network.

网络操作系统负责提供这些服务：

- 为每个接入网络的用户分配和管理账号。
- 管理网络上的所有资源。
- 在网络上提供跨设备的资源共享服务。
- 控制能访问的资源的权限。
- 监控和排除网络故障。

NOS可以分为CS架构和P2P架构。很显然BOS属于后者。

## **LibertyOS**

官网在[LibertyOS - Blockchain Operating System](https://libertyos.net/)。它非常自信地标榜自己是世界上第一个区块链OS。

看了看官网，它是这么介绍自己的：

- 普通操作系统能做的事情它也能做（办公，游戏等）
- 为多种区块链货币的钱包提供原生支持

这样来看，很像是传统的操作系统装了一大堆钱包软件之后的样子？

## ethOS

官网在[ethOS - Crypto native mobile operating system (ethosmobile.org)](https://www.ethosmobile.org/)。自称是世界上第一个以太坊操作系统，是移动设专属的。

> ethOS是一个开源的以太坊原生移动操作系统，它可以让用户在手机上体验去中心化的网络和应用。以下是从当前页面中提取的一些关于ethOS的信息：
>
> - **创新特点**：ethOS是世界上第一个以太坊原生的移动操作系统，它集成了系统级钱包、去中心化的消息和支付、ENS域名服务、轻节点（不下载完整区块，只下载区块头的节点）等功能，让用户可以在手机上直接与以太坊网络交互。
> - **安装方式**：ethOS可以通过简单的网页安装器安装在OEM解锁的谷歌Pixel 3, 3XL或5a手机上，安装后可以自动接收未来的更新。ethOS也可以在模拟器上运行，只需按照详细的说明进行设置。
> - **开发团队**：ethOS是一个有机的、开源的、社区驱动的项目，由来自全球的个人共同开发。开发者可以在Discord和Github上找到ethOS的团队和代码。
> - **参与方式**：用户可以购买一部OEM解锁的Pixel手机，安装ethOS，并在Discord上分享反馈意见。用户也可以在其他方面（代码、设计、营销、文案、法律等）为ethOS做出贡献，只需在Discord上自我介绍，分享自己的想法和能力。——new Bing

### 系统特点

这个系统并非完全从零开始编写的。实际上，它是从Android的一个分支——免费开源的LineageOS发展而来的。作为从底层支持区块链的依据，ethOS在其系统服务中就运行着一个以太坊轻节点客户端。虽然它并不保存所有区块的完整信息，却能独立地进行区块验证。

应用程序开发者仅需连接到系统提供的JSON-RPC服务器即可调用有关以太坊的各种系统调用，无需关注底层运行的逻辑。

### 轻节点支持

轻节点是一种轻量级、资源占用较小的以太坊节点，它只下载区块头，而不需要下载完整的区块。如果轻节点需要区块中包含的其他信息，它必须从完整节点请求。

ethOS Mobile的轻节点功能允许用户在任何有数据或WiFi连接的地方连接到以太坊网络，并通过自己的私有轻节点运行交易。这使得以太坊变得更加去中心化。

使用ethOS Mobile的轻节点功能，用户可以通过以下步骤：

1. 打开“轻节点”应用程序。
2. 在“设置”页面中，将“轻节点”切换为“开启”。
3. 选择要连接的轻节点客户端。目前，ethOS Mobile支持Nimbus轻节点客户端。

当轻节点处于“开启”状态时，用户将在状态栏中看到一个高亮显示的区块图标。这表示轻节点已成功连接到以太坊网络。

轻节点使用的数据量取决于其运行时间。根据ethOS Mobile团队的测量，轻节点在运行10分钟、1小时和24小时期间的数据使用量分别为0.02MB、0.1MB和1.2MB。

轻节点的使用可以提高以太坊网络的去中心化程度，因为它允许用户在任何地方运行自己的轻节点。

# 我的思考

首先，很多网络资料（包括开发者）都把能开发/运行Dapp的平台称为BOS，甚至将提供了一部分与区块链相关的安全性的软件也称为BOS。这给搜索资料带来了困难。经过筛选排除之后，我认为较为切题的两个BOS为上述介绍的LibertyOS和ethOS。

其次，关于上述两种BOS我个人认为：

- LibertyOS和我们的研究目标关系不大，因为从它的官方网站的介绍上来看，它仅仅是提供了一个钱包的应用程序，而实现这个目标根本无需操作系统内核来完成，直接写个用户态的应用程序就完事了。而且，它不是开源的，其官网上压根没open-source这个词，Github上也没找着它的仓库。
- ethOS和我们的研究目标关系很大，因为从它的介绍上来看，它从系统服务的层面对Android进行了改进，加入了一个运行在系统内核中的轻节点（以及供用户程序调用的JSON-RPC接口）。这个做法和思路我认为是切题的。

那么，我想将我的研究生生涯目标再细化为：**在rCore中，实现一个轻节点。**

> 轻节点指的是：一个不存储完整区块链所有信息，只存储区块头和相关信息的节点。
>
> 轻节点能消耗更少的资源完成与区块链网络的同步，但若它想获得某个区块的必要的完整信息，就必须依赖其他的设施，例如全节点和RPC服务器。
>
> 轻节点可以做如下的事情：
>
> - 借助密码学证明和协议（例如SPV或LCP）来查验收到的数据。
> - 从区块链网络请求某个数据。
> - 发送交易。

> 在一些资料中，轻节点和轻客户端往往被混合使用。虽然他们挺像的，但实际上不是一个东西。
>
> **节点**指的是参与区块链网络构成，并且和其他节点通信的**软件或硬件**。**客户端**指的是一种**特殊的节点**，它会从其他节点请求数据。也就是说，客户端是节点的**子集**。客户端一定是个节点，但节点不只有客户端这一种。
>
> 若一台设备安装了轻客户端，它就能以轻节点的身份参与到网络的建设中。

然而，主流的区块链平台（例如Polkadot和以太坊）的节点实现和客户端实现都非常复杂。不仅难以分析且依赖较多，不适合作为我的研究目标。那么，比较合适的做法是构造一个玩具私有链的轻节点。万幸，我发现了斯坦福大学EE374这门课，在该课上学生的作业就是用TypeScript自己实现一个玩具区块链的节点等内容。

# 参考资料

[Blockchain Operating System: A Complete Overview (blockchain-council.org)](https://www.blockchain-council.org/blockchain/blockchain-operating-system-a-complete-overview/)

>   Blockchain technology has the potential to enhance the security of an operating system in several ways. Here are a few possibilities:
>
>   1.  Decentralized Authentication: By using blockchain-based authentication, users can store their credentials in a decentralized and secure manner, reducing the risk of credential theft or manipulation.
>   2.  Secure Storage: Blockchain technology can be used to create secure data storage solutions where sensitive information can be stored in an encrypted format. This can help protect user data from unauthorized access or tampering.
>   3.  Transparency and Auditability: Blockchain-based systems allow for the creation of immutable records, which can be used to track system events and detect any suspicious activity. This transparency can help enhance the overall security of an operating system.
>   4.  Smart Contracts: The use of smart contracts can automate many processes and enforce security policies within the operating system. This can help reduce the risk of human error or intentional misuse of the system.
>   5.  Identity Management: Blockchain-based identity management systems can enable users to have more control over their personal information, reducing the risk of identity theft and fraud.
>   6.  Supply Chain Security: Using blockchain technology can improve supply chain management by tracking the origin and movement of hardware and software components, reducing the risk of counterfeit or compromised parts being introduced into the system.
>
>   However, it's important to note that implementing blockchain technology in an operating system is a complex task and requires careful consideration of various technical, organizational, and regulatory aspects.  —— Stable Chat

>   了解区块链如何为操作系统带来安全性提升的研究资料可能并不多，因为这是一个相对新兴的研究领域。以下是一些建议和可能的方向：
>
>   1.  **密码学安全性**：区块链技术中的密码学安全性包括签名、验签、Hash摘要等。当前的技术水平下，绝大部分区块链技术采用的密码学算法都是安全的。
>   2.  **共识机制**：共识机制的方案特性决定着区块链网络交易的吞吐量和安全性。
>   3.  **数据隐私保护**：区块链可以对数据隐私进行保护，防止数据被篡改或泄露。
>   4.  **提高数据可信性和安全性**：国家信息中心表示，区块链技术利用其分布式、透明性、可追溯、防篡改等特征，可以提高社会治理中数据的可信性和安全性。
>
>   您可以考虑从以下几个方向进行深入研究：
>
>   -   **区块链与操作系统的集成**：研究如何将区块链技术直接集成到操作系统中，以提高整体的安全性。
>   -   **区块链在数据安全中的应用**：探讨如何使用区块链技术来保护存储在操作系统中的数据，特别是在多用户或分布式环境中。
>   -   **持续关注政策和行业动态**：如工业和信息化部、中央网络安全和信息化委员会办公室发布的关于加快推动区块链技术应用和产业发展的指导意见，这些政策可能会为您的研究提供方向。 —— 讯飞星火

