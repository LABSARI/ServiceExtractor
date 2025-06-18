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

{ #category : 'generating' }
SpringControllerGenerator >> declaredTypeFor: aType [

	^ String streamContents: [ :s |
		  s << aType name.
		  aType isParametricEntity ifTrue: [
			  s << '<'.
			  aType concreteParameters
				  do: [ :concreteParameter |
					  concreteParameter isParametricEntity 
						  ifTrue: [ s << s declaredTypeFor: concreteParameter ]
						  ifFalse: [ s << concreteParameter name ] ]
				  separatedBy: [ s << ',' ].
			  s << '>' ] ]
]

{ #category : 'generating' }
SpringControllerGenerator >> generateClassController [

	| controllerClass controllerAnnotation controllerAnnotationInstance cAttribute |
	controllerClass := FamixJavaClass
		                   named: daoClass name , 'Controller'
		                   model: model.
	controllerAnnotation := FamixJavaAnnotationType new
		                        name: 'RestController';
		                        typeContainer:
			                        (FamixJavaPackage named:
					                         'org.springframework.web.bind.annotation');
		                        yourself.
	controllerAnnotationInstance := FamixJavaAnnotationInstance new
		                                annotationType: controllerAnnotation.
		
		
	cAttribute := FamixJavaAttribute named: daoClass name asValidSelector.
	cAttribute declaredType: daoClass.
	controllerClass addAttribute: cAttribute.
	controllerClass annotationInstances add: controllerAnnotationInstance.
	self generateConstructorIn: controllerClass.
	self generateMethodsIn: controllerClass.
	^ controllerClass
]

{ #category : 'generating' }
SpringControllerGenerator >> generateConstructorIn: aClass [

	| constructor sourceAnchor |
	constructor := FamixJavaMethod named: aClass name.
	constructor isConstructor: true.
	sourceAnchor := FamixJavaSourceAnchorSE new.
	sourceAnchor customSourceText:
		(self generateConstructorTextFor: aClass).
	aClass attributes do: [ :att |
		constructor addParameter: ((FamixJavaParameter named: att name)
				 declaredType: att declaredType;
				 yourself) ].
	constructor
		parentType: aClass;
		sourceAnchor: sourceAnchor;
		isPublic: true
]

{ #category : 'generating' }
SpringControllerGenerator >> generateConstructorTextFor: aClass [

	^ String streamContents: [ :s |
		  s << aClass name.
		  s << '{'.
		  aClass attributes do: [ :att |
			  s
				  << '		this.';
				  << att name;
				  << ' = ';
				  << att name;
				  << ';';
				  << String cr ].
		  s << '}' ]
]

{ #category : 'generating' }
SpringControllerGenerator >> generateControllerFor: aClass [

	| p |
	daoClass := aClass.
	model := FamixJavaModel new.
	p := model newPackageNamed: 'p'.
	p addType: self generateClassController.
	FAMIX2JavaVisitor new
		rootFolder: FileSystem workingDirectory ;
		export: model. 
	
	
]

{ #category : 'generating' }
SpringControllerGenerator >> generateDeclaredTypeFor: aMethod [

	^ aMethod declaredType
]

{ #category : 'generating' }
SpringControllerGenerator >> generateMethod: aMethod in: aControllerClass [

	| controllerMethod parameters sourceAnchor annotationInstance postMapping|
	controllerMethod := FamixJavaMethod named: aMethod name model: model.
	sourceAnchor := FamixJavaSourceAnchorSE new.
	sourceAnchor customSourceText: (self generateSourceTextFor: aMethod).
	parameters := aMethod parameters asOrderedCollection collect: #copy.

	postMapping := FamixJavaAnnotationType new
		                        name: 'PostMapping("', '/' , controllerMethod name, '")';
		                        typeContainer:
			                        (FamixJavaPackage named:
					                         'org.springframework.web.bind.annotation');
		                        yourself.
	annotationInstance := FamixJavaAnnotationInstance new
		                      annotationType: postMapping;
		                      annotatedEntity: controllerMethod;
		                      yourself.

	controllerMethod
		parentType: aControllerClass;
		isPublic: true;
		declaredType: (self generateDeclaredTypeFor: aMethod);
		parameters: parameters;
		sourceAnchor: sourceAnchor
]

{ #category : 'generating' }
SpringControllerGenerator >> generateMethodsIn: aControllerClass [
	
	(daoClass methods reject: [ :m | m name ='<Initializer>' ]) do: [ :method |
		self generateMethod: method in: aControllerClass
		 ]
]

{ #category : 'generating' }
SpringControllerGenerator >> generateSourceTextFor: aMethod [

	^ '{5}\{
		{1} {2} = {3}.{4};
		ResponseEntity.ok({2});
	\}' format: {
			  (self declaredTypeFor: aMethod declaredType).
			  (self nameFor: aMethod declaredType).
			  daoClass name asValidSelector.
			  self methodCallTo: aMethod.
			  aMethod name }
]

{ #category : 'generating' }
SpringControllerGenerator >> methodCallTo: aMethod [

	^ String streamContents: [ :s |
		  s << aMethod name.
		  s << '('.
		  aMethod parameters
			  do: [ :param | s << param name ]
			  separatedBy: [ s << ',' ].
		  s << ')' ]
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods [

	^ methods
]

{ #category : 'accessing' }
SpringControllerGenerator >> methods: anObject [

	methods := anObject
]

{ #category : 'generating' }
SpringControllerGenerator >> nameFor: aType [

	
	^ 'a', (aType name asValidSelector).
]

{ #category : 'accessing' }
SpringControllerGenerator >> path [

	^ path
]

{ #category : 'accessing' }
SpringControllerGenerator >> path: anObject [

	path := anObject
]
