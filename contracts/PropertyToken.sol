// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract PropertyToken is ERC20 {
    uint256 private property_price_in_ETH;
    uint256 private totalTokens;
    string  private official_docs_link; // IPFS link  for example // https://ipfs.io/ipfs/QmWx6QtvxiAiVDkqh3bC5mUxatqLzck4xH9eGvCuCqFFvC
    address owner;

    mapping(address => uint256) public pendingSales; // address : seller , uint256 : amount of tokens

    // events 
    event TokensCreated(uint256 amount);
    event TokensPurchased(uint256 amount, address buyer);
    event TokensSold(uint256 amount, address  seller, address buyer);
    event TokensBurned(uint256 amount, address _addr);
    event  WithdrawFundsDone(uint256 amount, address _addr);


    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _price_in_ETH,
        uint256 _totalTokens,
        string memory _official_docs_link

    ) ERC20(_name, _symbol) {
        
        require(_totalTokens > 0, "Token amount must be greater than 0");
        owner = msg.sender;
        totalTokens =_totalTokens;

        property_price_in_ETH = _price_in_ETH; 
        official_docs_link = _official_docs_link;

       // _mint(owner, _totalTokens); // Mint 1  of _totalTokens number of tokens | 10^18 
        _mint(address(this), _totalTokens); 
        emit TokensCreated(_totalTokens); 
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function updatePropertyPrice (uint256 _newPriceEth) onlyOwner public
    {
        property_price_in_ETH = _newPriceEth;
    }

    function updateOfficialDocLink (string memory _official_docs_link) onlyOwner public
    {
        official_docs_link = _official_docs_link;
    }

    function getPropertyPrice()  public view returns(uint256) 
    {
        return property_price_in_ETH;
    }

    function getOfficialDocLink()  public view returns(string memory)
    {
        return official_docs_link ;
    }
    
    function getTotalTokens()  public view returns(uint256)
    {
        return totalTokens ;
    }

    function buyTokens(uint256 _desiredTokens) external payable {
        require(msg.value > 0, "Ethereum amount must be greater than 0");
        require(_desiredTokens > 0, "desired tokens value should be greater than 0");
        require(address(this).balance  > _desiredTokens, "Not enough tokens available to sell");

        // Calculate the equivalent amount of tokens based on the value sent
        uint256 valuePerToken = property_price_in_ETH / totalTokens;
        uint256 tokensToBuyValueEth = (_desiredTokens * valuePerToken) / 1 ether;

        require(msg.value >= tokensToBuyValueEth, "Ethereum amount must be greater than tokensToBuyValueEth (bc. gaz fees)");

        // Transfer tokens to the buyer
        _transfer(owner, msg.sender, _desiredTokens);

        // Emit an event indicating the purchase
        emit TokensPurchased(_desiredTokens, msg.sender);
    }

    function transferTokens(address _to, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens to transfer");

        _transfer(msg.sender, _to, _amount);
    }

    // selling tokens :
    function sellTokens( uint256 _desiredTokens) external {
        require(_desiredTokens > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= _desiredTokens, "Not enough tokens to sell");

        // Transfer the tokens to this contract
        _transfer(msg.sender, address(this), _desiredTokens);

        // Record the pending sale
        pendingSales[msg.sender] = _desiredTokens;
    }

    function buyTokens_secondMarket(address _seller) external payable {
        require(_seller != address(0), "Not valid address, 0 !");

        uint256 amount = pendingSales[_seller];
        require(amount != 0, "No more tokens available from seller, 0 !");
        
        // Calculate the equivalent amount of tokens based on the value sent
        uint256 valuePerToken = property_price_in_ETH/ totalTokens;
        uint256 tokensToBuyValueEth = (amount * valuePerToken) / 1 ether;
        require(msg.value >= tokensToBuyValueEth, "Ethereum amount must be greater than tokensToBuyValueEth (bc. gaz fees)");

        // Transfer the tokens to the buyer
        _transfer(address(this), msg.sender, amount);

        // Transfer the ETH to the seller
        payable(_seller).transfer(tokensToBuyValueEth);

        // Clear the pending sale
        delete pendingSales[msg.sender];
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= address(this).balance, "Invalid withdrawal amount");

        payable(owner).transfer(_amount);
    }

    function burn(uint256 amount) external {
        _burn(address(this), amount);
        emit TokensBurned(amount, msg.sender);
    }

}



