public class GetSharePointFilesResponse {

	public class d {
		public List<Results> results {get;set;} 

		public d(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'results') {
							results = arrayOfResults(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'd consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Results {
		public Author Author {get;set;} 
		public Author CheckedOutByUser {get;set;} 
		public Author EffectiveInformationRightsManagementSettings {get;set;} 
		public Author InformationRightsManagementSettings {get;set;} 
		public Author ListItemAllFields {get;set;} 
		public Author LockedByUser {get;set;} 
		public Author ModifiedBy {get;set;} 
		public Author Properties {get;set;} 
		public Author VersionEvents {get;set;} 
		public Author Versions {get;set;} 
		public String CheckInComment {get;set;} 
		public Integer CheckOutType {get;set;} 
		public String ContentTag {get;set;} 
		public Integer CustomizedPageStatus {get;set;} 
		public String ETag {get;set;} 
		public Boolean Exists {get;set;} 
		public Boolean IrmEnabled {get;set;} 
		public String Length {get;set;} 
		public Integer Level {get;set;} 
		public String LinkingUri {get;set;} 
		public String LinkingUrl {get;set;} 
		public Integer MajorVersion {get;set;} 
		public Integer MinorVersion {get;set;} 
		public String Name {get;set;} 
		public String ServerRelativeUrl {get;set;} 
		public String TimeCreated {get;set;} 
		public String TimeLastModified {get;set;} 
		public String Title {get;set;} 
		public Integer UIVersion {get;set;} 
		public String UIVersionLabel {get;set;} 
		public String UniqueId {get;set;} 

		public Results(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Author') {
							Author = new Author(parser);
						} else if (text == 'CheckedOutByUser') {
							CheckedOutByUser = new Author(parser);
						} else if (text == 'EffectiveInformationRightsManagementSettings') {
							EffectiveInformationRightsManagementSettings = new Author(parser);
						} else if (text == 'InformationRightsManagementSettings') {
							InformationRightsManagementSettings = new Author(parser);
						} else if (text == 'ListItemAllFields') {
							ListItemAllFields = new Author(parser);
						} else if (text == 'LockedByUser') {
							LockedByUser = new Author(parser);
						} else if (text == 'ModifiedBy') {
							ModifiedBy = new Author(parser);
						} else if (text == 'Properties') {
							Properties = new Author(parser);
						} else if (text == 'VersionEvents') {
							VersionEvents = new Author(parser);
						} else if (text == 'Versions') {
							Versions = new Author(parser);
						} else if (text == 'CheckInComment') {
							CheckInComment = parser.getText();
						} else if (text == 'CheckOutType') {
							CheckOutType = parser.getIntegerValue();
						} else if (text == 'ContentTag') {
							ContentTag = parser.getText();
						} else if (text == 'CustomizedPageStatus') {
							CustomizedPageStatus = parser.getIntegerValue();
						} else if (text == 'ETag') {
							ETag = parser.getText();
						} else if (text == 'Exists') {
							Exists = parser.getBooleanValue();
						} else if (text == 'IrmEnabled') {
							IrmEnabled = parser.getBooleanValue();
						} else if (text == 'Length') {
							Length = parser.getText();
						} else if (text == 'Level') {
							Level = parser.getIntegerValue();
						} else if (text == 'LinkingUri') {
							LinkingUri = parser.getText();
						} else if (text == 'LinkingUrl') {
							LinkingUrl = parser.getText();
						} else if (text == 'MajorVersion') {
							MajorVersion = parser.getIntegerValue();
						} else if (text == 'MinorVersion') {
							MinorVersion = parser.getIntegerValue();
						} else if (text == 'Name') {
							Name = parser.getText();
						} else if (text == 'ServerRelativeUrl') {
							ServerRelativeUrl = parser.getText();
						} else if (text == 'TimeCreated') {
							TimeCreated = parser.getText();
						} else if (text == 'TimeLastModified') {
							TimeLastModified = parser.getText();
						} else if (text == 'Title') {
							Title = parser.getText();
						} else if (text == 'UIVersion') {
							UIVersion = parser.getIntegerValue();
						} else if (text == 'UIVersionLabel') {
							UIVersionLabel = parser.getText();
						} else if (text == 'UniqueId') {
							UniqueId = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Results consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Author {
		public Author(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						System.debug(LoggingLevel.WARN, 'Author consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public d d {get;set;} 

	public GetSharePointFilesResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'd') {
						d = new d(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'GetSharePointFilesResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static GetSharePointFilesResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new GetSharePointFilesResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Results> arrayOfResults(System.JSONParser p) {
        List<Results> res = new List<Results>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Results(p));
        }
        return res;
    }


}