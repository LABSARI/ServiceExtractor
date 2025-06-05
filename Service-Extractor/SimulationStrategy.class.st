"
I am a strategy used by the simulation.
"
Class {
	#name : 'SimulationStrategy',
	#superclass : 'Object',
	#instVars : [
		'simulation'
	],
	#category : 'Service-Extractor-Simulation',
	#package : 'Service-Extractor',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
SimulationStrategy >> simulation [

	^ simulation
]

{ #category : 'accessing' }
SimulationStrategy >> simulation: anObject [

	simulation := anObject
]
