import "MetadataViews"
import "ExampleNFT"

access(all)
fun main(): AnyStruct {
    let address: Address = 0x02
    let id: UInt64 = 0
    
    let account = getAccount(address)

    // Borrow the collection's ResolverCollection capability
    let collection = account.capabilities.borrow<&{MetadataViews.ResolverCollection}>(
        /public/exampleNFTCollection
    ) ?? panic("Could not borrow a reference to the collection at /public/exampleNFTCollection")

    // Borrow the NFT's Resolver reference
    let nft = collection.borrowViewResolver(id: id)
        ?? panic("Could not resolve NFT with ID \(id) in the collection")

    // Get the Traits view for the NFT
    let traitsView = nft.resolveView(Type<MetadataViews.Traits>()) 
        ?? panic("Traits view not found for NFT with ID \(id)")

    // Get the Display view for the NFT
    let displayView = nft.resolveView(Type<MetadataViews.Display>())
        ?? panic("Display view not found for NFT with ID \(id)")

    // Combine the views into a dictionary
    let object = {"Traits": traitsView, "Display": displayView}

    return object
}