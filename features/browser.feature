Feature: Browse Repository
	In order to view a repository
	As a user
	I want view information about files and directories
	
	Scenario: Browse a Folder
		Given a repository exists with name: "warehouse", slug: "warehouse", path: "/Users/alex/Documents/Projects/Gems/shorty"
		When I am on warehouses's browser page
		Then I should see "warehouse" within "h1"
