
title 'Check Azure Resources'

control 'azure-storage-account-2.0' do

  impact 1.0
  title 'Check the storage account'

  # Get the storage account by type, this is because in the tests
  # the storage account name is randomly generated so it cannot be known to perform
  # these inspec tests
  describe azure_resource(group_name: 'Inspec-Azure',
                          type: 'Microsoft.Storage/storageAccounts') do
    its('total') { should be 1 }

    its('properties.encryption.keySource') { should cmp 'Microsoft.Storage' }

    # Check that the blob and file services are enabled
    its('properties.encryption.services.blob.enabled') { should be true }
    its('properties.encryption.services.file.enabled') { should be true }

    # Check the ACLs
    describe described_class.properties.networkAcls do
      its('bypass') { should cmp 'AzureServices' }
      its('defaultAction') { should cmp 'Allow' }
      its('ipRules.count') { should eq 0 }
      its('virtualNetworkRules.count') { should eq 0 }
    end

    # Determine if it only supports HTTPS traffic
    its('properties.supportsHttpsTrafficOnly') { should be false }
  end
end