<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <?= $this->Html->charset(); ?>
        <title>
            Wingolf Mitgliederbereich
        </title>
        <?php
        echo $this->Html->meta('icon');
        echo $this->Html->meta('description', '');
        echo $this->Html->meta('keywords', '');
        echo $this->Html->css('global');
        echo '
            <script type="text/javascript">
                var webroot = "' . Configure::read('App.base') . '";
            </script>
        ';
        echo $this->Html->script('jquery-1.7.1.min');
        echo $this->Html->script('jquery.fancybox-1.3.4.pack');
        echo $this->Html->script('jquery.slidingmessage.min');
        echo $this->Html->script('jquery.tools.min');
        echo $this->Html->script('global');
        echo $scripts_for_layout;
        ?>
    </head>
    <body>
        <span class="tooltip">&nbsp;</span>
        <div id="flashMessage"><?= $this->Session->flash(); ?><?= $this->Session->flash('auth') ?></div>
        <div id="content">
            <?= $content_for_layout; ?>
        </div>
        <?= $this->element('sql_dump'); ?>
    </body>
</html>