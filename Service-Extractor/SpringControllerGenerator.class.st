Class {
	#name : 'SpringControllerGenerator',
	#superclass : 'Object',
	#instVars : [
		'daoClass',
		'methods',
		'path',
		'model'
	],
	#category : 'Service-Extractor-Extractor',
	#package : 'Service-Extractor',
	#tag : 'Extractor'
}

{ #category : 'accessing' }
SpringControllerGenerator >> daoClass [

	^ daoClass
]

{ #category : 'accessing' }
SpringControllerGenerator >> daoClass: anObject [

	daoClass := anObject
]

{ #category : 'as yet unclassified' }
SpringControllerGenerator >> generateClassController [

	| controllerClass |
	controllerClass := FamixJavaClass named:  daoClass name, 'Controller.java' model: model.
	
	self generateMethodsIn: controllerClass
]

{ #category : 'as yet unclassified' }
SpringControllerGenerator >> generateControllerFor: aClass [

	daoClass := aClass.
	model := FamixJavaModel new.
	self generateClassController
	
	
]

{ #category : 'as yet unclassified' }
SpringControllerGenerator >> generateFileAt: aPath [

	| fileReference |
	fileReference := (aPath, '/', daoClass name, 'Controller.java') asFileReference.
	fileReference ensureCreateFile.
]

{ #category : 'as yet unclassified' }
SpringControllerGenerator >> generateMethod: aMethod in: aControllerClass [

	| controllerMethod |
	controllerMethod := FamixJavaMethod named: aMethod name model: model.
	controllerMethod
		parentType: aControllerClass;
		isPublic: true;
		"declaredType: (self generateDeclaredTypeFor: aMethod);"
		parameters: aMethod parameters.
		
]

{ #category : 'as yet unclassified' }
SpringControllerGenerator >> generateMethodsIn: aControllerClass [


	daoClass methods do: [ :method |
		self generateMethod: method in: aControllerClass
		 ]
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods [

	^ methods
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods: anObject [

	methods := anObject
]

{ #category : 'accessing' }
SpringControllerGenerator >> path [

	^ path
]

{ #category : 'accessing' }
SpringControllerGenerator >> path: anObject [

	path := anObject
]
