mod dapp {
    pub mod ApplicationFactory;
}
mod inputs {
    pub mod InputBox;
}
mod portals {
    pub mod Portal;
    pub mod Erc20Portal;
    pub mod Erc721Portal;
    pub mod Erc1155SinglePortal;
    pub mod Erc1155BatchPortal;
}
mod common {
    pub mod CanonicalMachine;
    pub mod InputEncoding;
    pub mod Inputs;
    pub mod Outputs;
    pub mod OutputValidityProof;
}
mod library {
    pub mod LibError;
    pub mod LibAddress;
    pub mod LibMerkle32;
    pub mod LibOutputValidityProof;
}