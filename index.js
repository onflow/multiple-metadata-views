// Pass the repo name
const recipe = "multiple-metadata-views";

//Generate paths of each code file to render
const contractPath = `${recipe}/cadence/contract.cdc`;
const transactionPath = `${recipe}/cadence/transaction.cdc`;

//Generate paths of each explanation file to render
const smartContractExplanationPath = `${recipe}/explanations/contract.txt`;
const transactionExplanationPath = `${recipe}/explanations/transaction.txt`;

export const multipleMetadataViews = {
  slug: recipe,
  title: "Multiple Metadata Views",
  createdAt: Date(2022, 3, 1),
  author: "Flow Blockchain",
  playgroundLink:
    "https://play.onflow.org/41befd2d-31f3-47f0-ae30-aad776961e31?type=script&id=baf002e4-7124-4ffb-894e-5c04e95629de",
  excerpt:
    "Have more views you want to create for metadata? This is how you create new views in your smart contract and how you execute a transaction to display them all",
  smartContractCode: contractPath,
  smartContractExplanation: smartContractExplanationPath,
  transactionCode: transactionPath,
  transactionExplanation: transactionExplanationPath,
};
