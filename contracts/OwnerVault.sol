// SPDX-License-Identifier: MIT
pragma solidity ^0.8.38;

/// @notice Owner controlled vault for ETH, ERC-20, ERC-721 and ERC-1155 assets.
/// @dev Tokens held by an EOA are only movable after that EOA grants this
///      contract the relevant allowance or token approval.
contract OwnerVault {
    address public immutable owner;

    error NotOwner();
    error ZeroAddress();
    error TransferFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address owner_) {
        if (owner_ == address(0)) revert ZeroAddress();
        owner = owner_;
    }

    receive() external payable {}

    function withdrawETH(address payable recipient, uint256 amount) external onlyOwner {
        if (recipient == address(0)) revert ZeroAddress();
        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    /// @notice Move ERC-20 tokens already in the vault or approved by the owner.
    function transferERC20(address token, address from, address to, uint256 amount) external onlyOwner {
        if (token == address(0) || from == address(0) || to == address(0)) revert ZeroAddress();
        (bool success, bytes memory result) = token.call(
            abi.encodeWithSelector(IERC20Vault.transferFrom.selector, from, to, amount)
        );
        if (!success || (result.length != 0 && !abi.decode(result, (bool)))) revert TransferFailed();
    }

    /// @notice Set or revoke an ERC-20 allowance for tokens held by this vault.
    function approveERC20(address token, address spender, uint256 amount) external onlyOwner {
        if (token == address(0) || spender == address(0)) revert ZeroAddress();
        (bool success, bytes memory result) = token.call(
            abi.encodeWithSelector(IERC20Vault.approve.selector, spender, amount)
        );
        if (!success || (result.length != 0 && !abi.decode(result, (bool)))) revert TransferFailed();
    }

    function transferERC721(address token, address from, address to, uint256 tokenId) external onlyOwner {
        if (token == address(0) || from == address(0) || to == address(0)) revert ZeroAddress();
        IERC721Vault(token).transferFrom(from, to, tokenId);
    }

    function transferERC721Safe(address token, address from, address to, uint256 tokenId) external onlyOwner {
        if (token == address(0) || from == address(0) || to == address(0)) revert ZeroAddress();
        IERC721Vault(token).safeTransferFrom(from, to, tokenId);
    }

    /// @notice Approve or revoke an ERC-721 token held by this vault.
    function approveERC721(address token, address approved, uint256 tokenId) external onlyOwner {
        if (token == address(0)) revert ZeroAddress();
        IERC721Vault(token).approve(approved, tokenId);
    }

    /// @notice Approve or revoke an operator for all ERC-721 tokens held by this vault.
    function setApprovalForAllERC721(address token, address operator, bool approved) external onlyOwner {
        if (token == address(0) || operator == address(0)) revert ZeroAddress();
        IERC721Vault(token).setApprovalForAll(operator, approved);
    }

    function transferERC1155(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) external onlyOwner {
        if (token == address(0) || from == address(0) || to == address(0)) revert ZeroAddress();
        IERC1155Vault(token).safeTransferFrom(from, to, tokenId, amount, data);
    }

    function transferERC1155Batch(
        address token,
        address from,
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external onlyOwner {
        if (token == address(0) || from == address(0) || to == address(0)) revert ZeroAddress();
        IERC1155Vault(token).safeBatchTransferFrom(from, to, tokenIds, amounts, data);
    }

    /// @notice Approve or revoke an operator for all ERC-1155 tokens held by this vault.
    function setApprovalForAllERC1155(address token, address operator, bool approved) external onlyOwner {
        if (token == address(0) || operator == address(0)) revert ZeroAddress();
        IERC1155Vault(token).setApprovalForAll(operator, approved);
    }
}

interface IERC20Vault {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC721Vault {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function approve(address approved, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
}

interface IERC1155Vault {
    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
    function setApprovalForAll(address operator, bool approved) external;
}
