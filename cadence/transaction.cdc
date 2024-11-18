import MetadataViews from 0x01
import NewExampleNFT from 0x02

access(all)
fun main(): AnyStruct {
    let address: Address = 0x02
    let id: UInt64 = 0
    
    let account = getAccount(address)

    // Borrow the collection's ResolverCollection capability
    let collection = account.capabilities.borrow<&{MetadataViews.ResolverCollection}>(
        /public/exampleNFTCollection
    ) ?? panic("Could not borrow a reference to the collection")

    // Borrow the NFT's Resolver reference
    let nft = collection.borrowViewResolver(id: id)

    // Get the Traits view for the NFT
    let view = nft.resolveView(Type<NewExampleNFT.Traits>())
    
    // Get the Display view for the NFT
    let oview = nft.resolveView(Type<MetadataViews.Display>())

    // Combine the views into a dictionary
    let object = {"Traits": view, "Display": oview}

    return object
}
