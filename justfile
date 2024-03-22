
generate_action image_tag:
	workflow-engine config generate-action docker://ghcr.io/cms-enterprise/batcave/workflow-engine:{{ image_tag }} > action.yml
