import * as n8nWorkflow from 'n8n-workflow';

export class ExampleCredentialsApi implements n8nWorkflow.ICredentialType {
	name = 'media39CredentialsApi';
	displayName = 'Example Credentials API';
	properties: n8nWorkflow.INodeProperties[] = [
		// The credentials to get from user and save encrypted.
		// Properties can be defined exactly in the same way as node properties.
		{
			displayName: 'User Name',
			name: 'username',
			type: 'string',
			default: '',
		},
		{
			displayName: 'Password',
			name: 'password',
			type: 'string',
			typeOptions: {
				password: true,
			},
			default: '',
		},
	];

	// This credential is currently not used by any node directly but the HTTP Request node can use it to make requests.
	// The credential is also testable due to the `test` property below
	authenticate: n8nWorkflow.IAuthenticateGeneric = {
		type: 'generic',
		properties: {
			auth: {
				username: '={{ $credentials.username }}',
				password: '={{ $credentials.password }}',
			},
			qs: {
				// Send this as part of the query string
				n8n: 'rocks',
			},
		},
	};

	// The block below tells how this credential can be tested
	test: n8nWorkflow.ICredentialTestRequest = {
		request: {
			baseURL: 'https://Media39.ru',
			url: 'https://media39.ru/credentials',
		},
	};
}
