//
import type { IExecuteFunctions, INodeExecutionData, INodeType, INodeTypeDescription } from 'n8n-workflow'
import { NodeConnectionType, NodeOperationError } from 'n8n-workflow'

export class ExampleNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'Media39 Node',
    name: 'exampleNode',
    group: ['transform'],
    version: 1,
    description: 'Media39 Node',
    defaults: {
      name: 'Media39 Node',
    },
    inputs: [NodeConnectionType.Main],
    outputs: [NodeConnectionType.Main],
    properties: [
      // Node properties which the user gets displayed and can change on the node.
      {
        displayName: 'Media39',
        name: 'Media39',
        type: 'string',
        default: '',
        placeholder: 'Placeholder value',
        description: 'The description text',
      },
    ],
  }

  // The function below is responsible for actually doing whatever this node is supposed to do. In this case, we're just appending the `myString` property with whatever the user has entered.
  // You can make async calls and use `await`.
  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData()

    let item: INodeExecutionData
    let myString: string

    // Iterates over all input items and add the key "myString" with the value the parameter "myString" resolves to.
    // (This could be a different value for each item in case it contains an expression)
    for (let itemIndex = 0; itemIndex < items.length; itemIndex++) {
      try {
        myString = this.getNodeParameter('Media39', itemIndex, '') as string
        item = items[itemIndex]

        item.json.myString = myString
      } catch (error) {
        // This node should never fail but we want to showcase how to handle errors.
        if (this.continueOnFail()) {
          items.push({ json: this.getInputData(itemIndex)[0].json, error, pairedItem: itemIndex })
        } else {
          // Adding `itemIndex` allows other workflows to handle this error
          if (error.context) {
            // If the error thrown already contains the context property,
            // only append the itemIndex
            error.context.itemIndex = itemIndex
            throw error
          }
          throw new NodeOperationError(this.getNode(), error, {
            itemIndex,
          })
        }
      }
    }

    return [items]
  }
}
