Class {
	#name : 'ServiceRemoveDominatedMethodsStrategy',
	#superclass : 'ServiceCodeRemovalStrategy',
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'computing' }
ServiceRemoveDominatedMethodsStrategy >> methodsToRemove [

	| removedMethods |
	removedMethods := simulation dominatedMethods.
	^ removedMethods
]
