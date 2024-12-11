import "NonFungibleToken"
import "MetadataViews"

access(all) contract ExampleNFT: NonFungibleToken {

    /// Standard Paths for the Collection
    access(all) let CollectionStoragePath: StoragePath
    access(all) let CollectionPublicPath: PublicPath

    /// Path where the minter should be stored
    access(all) let MinterStoragePath: StoragePath

    /// NFT Resource
    access(all) resource NFT: NonFungibleToken.NFT, MetadataViews.Resolver {

        access(all) let id: UInt64
        access(all) let name: String
        access(all) let description: String
        access(all) let thumbnail: String
        access(all) let traits: {String: String}

        access(self) let royalties: [MetadataViews.Royalty]

        init(
            name: String,
            description: String,
            thumbnail: String,
            traits: {String: String},
            royalties: [MetadataViews.Royalty]
        ) {
            self.id = self.uuid
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.traits = traits
            self.royalties = royalties
        }

        /// Returns the views supported by this NFT
        access(all) view fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.Royalties>(),
                Type<MetadataViews.Traits>()
            ]
        }

        /// Resolves the specified view for this NFT
        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(url: self.thumbnail)
                    )
                case Type<MetadataViews.Royalties>():
                    return MetadataViews.Royalties(
                        self.royalties
                    )
                case Type<MetadataViews.Traits>():
                    return MetadataViews.dictToTraits(self.traits)
            }
            return nil
        }
    }

    /// NFT Collection
    access(all) resource Collection: NonFungibleToken.Collection {

        /// Dictionary of owned NFTs
        access(all) var ownedNFTs: @{UInt64: {NonFungibleToken.NFT}}

        init() {
            self.ownedNFTs <- {}
        }

        /// Withdraws an NFT from the Collection
        access(NonFungibleToken.Withdraw) fun withdraw(withdrawID: UInt64): @{NonFungibleToken.NFT} {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("CustomNFT.Collection: Cannot withdraw NFT. ID not found.")
            return <-token
        }

        /// Deposits an NFT into the Collection
        access(all) fun deposit(token: @{NonFungibleToken.NFT}) {
            let token <- token as! @CustomNFT.NFT
            let id = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            destroy oldToken
        }

        /// Returns all NFT IDs in the Collection
        access(all) view fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Returns the number of NFTs in the Collection
        access(all) view fun getLength(): Int {
            return self.ownedNFTs.length
        }

        /// Borrows a reference to an NFT in the Collection
        access(all) view fun borrowNFT(_ id: UInt64): &{NonFungibleToken.NFT}? {
            return &self.ownedNFTs[id]
        }

        /// Creates an empty Collection and returns it
        access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
            return <-CustomNFT.createEmptyCollection()
        }
    }

    /// Minter for the NFT
    access(all) resource Minter {

        /// Mints a new NFT
        access(all) fun mintNFT(
            name: String,
            description: String,
            thumbnail: String,
            traits: {String: String},
            royalties: [MetadataViews.Royalty]
        ): @CustomNFT.NFT {
            return <-create NFT(
                name: name,
                description: description,
                thumbnail: thumbnail,
                traits: traits,
                royalties: royalties
            )
        }
    }

    /// Creates an empty Collection
    access(all) fun createEmptyCollection(): @{NonFungibleToken.Collection} {
        return <-create Collection()
    }

    init() {
        self.CollectionStoragePath = /storage/customNFTCollection
        self.CollectionPublicPath = /public/customNFTCollection
        self.MinterStoragePath = /storage/customNFTMinter

        // Create and save a Collection
        let collection <- create Collection()
        self.account.storage.save(<-collection, to: self.CollectionStoragePath)

        // Publish the Collection's capability
        let collectionCap = self.account.capabilities.storage.issue<&CustomNFT.Collection>(self.CollectionStoragePath)
        self.account.capabilities.publish(collectionCap, at: self.CollectionPublicPath)

        // Create and save a Minter
        let minter <- create Minter()
        self.account.storage.save(<-minter, to: self.MinterStoragePath)
    }
}
