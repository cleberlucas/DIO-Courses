// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizaTechDAO {
    address public dono;
    uint public totalAcoes;
    mapping(address => uint) public acoes;
    mapping(address => bool) public ehMembro;

    event AcoesCompradas(address indexed comprador, uint quantidade);
    event AcoesVendidas(address indexed vendedor, uint quantidade);
    event PropostaCriada(uint indexed idProposta, address indexed proponente, string descricao);
    event VotoRealizado(uint indexed idProposta, address indexed votante, bool voto, uint votos);

    struct Proposta {
        string descricao;
        uint votosSim;
        uint votosNao;
        mapping(address => bool) votou;
        bool executada;
    }

    Proposta[] public propostas;

    modifier apenasDono() {
        require(msg.sender == dono, "Apenas o dono pode chamar esta função");
        _;
    }

    modifier apenasMembro() {
        require(ehMembro[msg.sender], "Apenas membros podem chamar esta função");
        _;
    }

    constructor() {
        dono = msg.sender;
        totalAcoes = 1000;
        acoes[msg.sender] = totalAcoes;
        ehMembro[msg.sender] = true;
    }

    function comprarAcoes(uint quantidade) external payable {
        require(msg.value == quantidade, "Quantidade de pagamento incorreta");
        require(quantidade > 0 && quantidade <= (totalAcoes - acoes[msg.sender]), "Número inválido de ações");
        
        acoes[msg.sender] += quantidade;
        totalAcoes += quantidade;

        emit AcoesCompradas(msg.sender, quantidade);
    }

    function venderAcoes(uint quantidade) external {
        require(quantidade > 0 && quantidade <= acoes[msg.sender], "Número inválido de ações");

        acoes[msg.sender] -= quantidade;
        totalAcoes -= quantidade;
        payable(msg.sender).transfer(quantidade);

        emit AcoesVendidas(msg.sender, quantidade);
    }

    function criarProposta(string memory descricao) external apenasMembro {
        uint idProposta = propostas.length;
        propostas.push(Proposta({
            descricao: descricao,
            votosSim: 0,
            votosNao: 0,
            executada: false
        }));

        emit PropostaCriada(idProposta, msg.sender, descricao);
    }

    function votar(uint idProposta, bool voto) external apenasMembro {
        Proposta storage proposta = propostas[idProposta];
        require(!proposta.votou[msg.sender], "Você já votou");

        if (voto) {
            proposta.votosSim += acoes[msg.sender];
        } else {
            proposta.votosNao += acoes[msg.sender];
        }

        proposta.votou[msg.sender] = true;

        emit VotoRealizado(idProposta, msg.sender, voto, acoes[msg.sender]);
    }

    function executarProposta(uint idProposta) external apenasDono {
        Proposta storage proposta = propostas[idProposta];
        require(!proposta.executada, "Proposta já executada");
        require(proposta.votosSim > proposta.votosNao, "Não há votos suficientes para executar");

        proposta.executada = true;
    }
}
