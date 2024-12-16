import "MetadataViews"
import "ExampleNFT"

transaction {

    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Use the caller's address
        let address: Address = signer.address

        // Borrow the NFTMinter from the caller's storage
        let minter = signer.storage.borrow<&ExampleNFT.NFTMinter>(
            from: /storage/exampleNFTMinter
        ) ?? panic("Could not borrow the NFT minter reference.")

        // Mint a new NFT
        let nft <- minter.mintNFT(
            name: "Example NFT",
            description: "Minting a sample NFT",
            thumbnail: "https://example.com/thumbnail.png",
            royalties: [],
            metadata: {
                "Power": "100",
                "Will": "Strong",
                "Determination": "Unyielding"
            },
            
        )

        let id = nft.id

        // Borrow the collection capability to deposit the minted NFT
        let collection = signer.capabilities.borrow<&ExampleNFT.Collection>(
            /public/exampleNFTCollection
        ) ?? panic("Could not borrow the collection reference at /public/exampleNFTCollection.")

        // Deposit the minted NFT into the collection
        collection.deposit(token: <-nft)

        // Borrow the ViewResolver for the given NFT ID
        let resolver = collection.borrowViewResolver(id: id)
            ?? panic("Could not borrow the ViewResolver for the NFT ID.")

        // Get the Traits view for the NFT
        let traitsView = resolver.resolveView(Type<MetadataViews.Traits>()) 
            ?? panic("Traits view not found for NFT ID.")

        // Get the Display view for the NFT
        let displayView = resolver.resolveView(Type<MetadataViews.Display>())
            ?? panic("Display view not found for NFT ID.")

        let object = {"Traits": traitsView, "Display": displayView}
        log(object)
    }
}
