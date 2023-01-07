// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.16;

  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "@openzeppelin/contracts/utils/Strings.sol";

contract FOMO26 is ERC721Enumerable, Ownable {

	using Strings for uint256;

	string _baseTokenURI;

	uint256 NFTprice = 7 ether;

	uint256 public maxTokenIds = 26;
	uint256 public tokenIds;
	uint256 public deployedTimestamp;
	bool startMint = false;

	address withdrawWallet;

	constructor () ERC721("FOMO26", "FOMO26") {
		_baseTokenURI = "x";
		withdrawWallet = address(0);
		deployedTimestamp = block.timestamp;
	}

	function startMintFunc() public onlyOwner {
		startMint = true;
	}

	function _baseURI() internal view virtual override returns (string memory) {
		return _baseTokenURI;
	}

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
		require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

		string memory baseURI = _baseURI();
		return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
	}

	function getTimestamp() public view returns (uint256) {
		return block.timestamp;
	}

	function getPrice() public view returns (uint256) {

		uint256 newTime = block.timestamp - deployedTimestamp;
		uint256 priceToSubtract = 0.00001 ether * newTime;
		if(NFTprice <= priceToSubtract) {
			return 0;
		} else {
		uint256 price = NFTprice - priceToSubtract;
		return(price);
		}
	}

	function mintLetter() public payable {
		require(startMint, "Mint not active");
		require(tokenIds < maxTokenIds, "All passes minted");
		require(msg.value >= getPrice(), "Not enough eth sent");
		tokenIds += 1;
		_safeMint(msg.sender, tokenIds);
	}

	function withdraw() public onlyOwner {
		uint256 amount = address(this).balance;
		(bool sent, ) =  withdrawWallet.call{value: amount}("");
		require(sent, "Failed to send Ether");
	}

	// Function to receive Ether. msg.data must be empty
	receive() external payable {}

	// Fallback function is called when msg.data is not empty
	fallback() external payable {}
}
