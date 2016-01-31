# instances

Create and use Instances in your Kha project. Can be used directly as Kha library included in khafile.js.  

![](http://i.imgur.com/3qUdCZo.png?1)

## Getting started
- Clone into 'your_kha_project/Libraries'
- Add 'project.addLibrary('instances');' into khafile.js
``` hx

import instances.Instances;

class InstancesApplication {
	
	var instancesCollection : Instances;

	public function new() {
		instancesCollection = new Instances('cylinder',10,10);
    }

	public function render(frame: Framebuffer) {
		instancesCollection.render(frame);
    }
	
	public function update() {
		instancesCollection.updateAll();
	}
}

```

info : this kha library is based on this demo : https://github.com/AoE-Maniac/Kha-InstancedExample
(and this repository represents the port of this code to a kha lib for reusability) 
