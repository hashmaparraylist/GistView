//
//  ServerDefine.h
//  GistView
//
//  Created by Sebastian Qu on 15/6/28.
//  Copyright (c) 2015年 Sebastian Qu. All rights reserved.
//

#ifndef GistView_ServerDefine_h
#define GistView_ServerDefine_h

// Server Url
NSString * const API_ENDPOINT_URL = @"https://api.github.com";
NSString * const BASE_WEB_URL = @"https://github.com";

// API URL PATH
NSString * const AUTHORIZE_API = @"%@/login/oauth/authorize?client_id=%@&scope=%@&state=%@";
NSString * const ACCESS_TOKEN_API = @"%@/login/oauth/access_token";

// APP Setting
NSString * const CLIENT_ID = @"fafb0af1c792afc8aac6";
NSString * const CLIENT_SECRET = @"f30e7b2071b7dc763db53a38c0ad4528dadb013a";


#endif
